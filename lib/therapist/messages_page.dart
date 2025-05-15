import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MessagesPage extends StatefulWidget {
  final String therapistId;

  const MessagesPage({super.key, required this.therapistId});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  String? _selectedPatientId;
  final Map<String, List<String>> _messages = {};
  List<Map<String, String>> _patients = [];
  List<Map<String, String>> _filteredPatients = [];

  @override
  void initState() {
    super.initState();
    _fetchPatients();

    _searchController.addListener(() {
      _filterPatients(_searchController.text);
    });
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _filterPatients(String query) {
    setState(() {
      _filteredPatients = _patients
          .where((p) =>
          p['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _fetchPatients() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/users'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final patients = data
            .where((user) => user['type'] == 'patient')
            .map<Map<String, String>>((user) => {
          'id': user['_id'],
          'name': user['username'] ?? user['email'] ?? 'Patient',
        })
            .toList();

        patients.sort((a, b) =>
            a['name']!.toLowerCase().compareTo(b['name']!.toLowerCase()));

        setState(() {
          _patients = patients;
          _filteredPatients = patients;
        });
      } else {
        print('❌ Erreur récupération patients : ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur réseau : $e');
    }
  }

  Future<void> _loadConversation(String patientId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/api/messages/conversation/$patientId'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final messagesList = data['messages']
          .map<String>((msg) => msg['content'] as String)
          .toList();

      setState(() {
        _messages[patientId] = messagesList;
      });

      scrollToBottom();
    } else {
      print('❌ Erreur chargement conversation : ${response.body}');
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (_selectedPatientId != null && message.isNotEmpty && token != null) {
      try {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:5000/api/messages/send'),
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': 'Bearer $token',
          },
          body: utf8.encode(jsonEncode({
            'receiverId': _selectedPatientId,
            'content': message,
          })),
        );

        if (response.statusCode == 201) {
          setState(() {
            _messages[_selectedPatientId!] = _messages[_selectedPatientId!] ?? [];
            _messages[_selectedPatientId!]!.add(message);
            _messageController.clear();
          });

          scrollToBottom();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Message envoyé à ${_selectedPatientId!}")),
          );
        } else {
          print('❌ Erreur lors de l\'envoi : ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erreur lors de l'envoi du message.")),
          );
        }
      } catch (e) {
        print('❌ Exception : $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur réseau : $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sélectionne un patient et écris un message.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final showDropdown = _searchFocusNode.hasFocus || _searchController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Messagerie Thérapeute'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: const InputDecoration(
                labelText: 'Rechercher un patient',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            if (showDropdown)
              SizedBox(
                height: 150,
                child: ListView.builder(
                  itemCount: _filteredPatients.length,
                  itemBuilder: (context, index) {
                    final patient = _filteredPatients[index];
                    return ListTile(
                      title: Text(patient['name']!),
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _selectedPatientId = patient['id'];
                          _searchController.text = patient['name']!;
                        });
                        _loadConversation(patient['id']!);
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                children: (_messages[_selectedPatientId] ?? []).map((msg) {
                  final now = DateTime.now();
                  final formattedTime =
                      "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(msg, style: const TextStyle(fontSize: 16, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(
                            formattedTime,
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Écrire un message',
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _sendMessage,
              child: const Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
  }
}

