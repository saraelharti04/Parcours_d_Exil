import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PatientMessagesPage extends StatefulWidget {
  final String patientId;
  final ValueNotifier<bool> hasNewMessagesNotifier;

  const PatientMessagesPage({
    super.key,
    required this.patientId,
    required this.hasNewMessagesNotifier,
  });
  @override
  State<PatientMessagesPage> createState() => _PatientMessagesPageState();
}

class _PatientMessagesPageState extends State<PatientMessagesPage> {
  List<dynamic> messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      print('❌ Aucun token trouvé dans SharedPreferences');
      return;
    }

    final url = Uri.parse('https://parcours-d-exil.onrender.com/api/messages/received');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      setState(() {
        messages = (json['messages'] as List)
          ..sort((a, b) => DateTime.parse(a['timestamp'])
              .compareTo(DateTime.parse(b['timestamp'])));
      });
      final userId = prefs.getString('user_id');
      if (messages.isNotEmpty && userId != null) {
        final newestMessageId = messages.last['_id'];
        await prefs.setString('last_seen_message_id_$userId', newestMessageId);
        widget.hasNewMessagesNotifier.value = false;
      }
      scrollToBottom();
    } else {
      print('❌ Erreur ${response.statusCode}: ${response.body}');
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Color _colorForUsername(String username) {
    final hash = username.codeUnits.fold(0, (prev, c) => prev + c);
    final colors = [
      Colors.teal,
      Colors.blue,
      Colors.deepPurple,
      Colors.orange,
      Colors.pink,
      Colors.indigo,
      Colors.green
    ];
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Supprime la flèche
        title: const Text('Messages reçus'),
      ),
      body: messages.isEmpty
          ? const Center(child: Text('📩 Vous n\'avez reçu aucun message.'))
          : ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[index];
          final content = msg['content'] ?? '';
          final sender = msg['senderId']?['username'] ?? 'Thérapeute';
          final color = _colorForUsername(sender);
          final timestamp = DateTime.tryParse(msg['timestamp'] ?? '');
          final formattedDate = timestamp != null
              ? "${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year}"
              : '';
          final formattedTime = timestamp != null
              ? "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}"
              : '';

          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8E8E8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sender,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(content,
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    '$formattedDate à $formattedTime',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
