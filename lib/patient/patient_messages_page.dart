import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PatientMessagesPage extends StatefulWidget {
  final String patientId;

  const PatientMessagesPage({super.key, required this.patientId});

  @override
  State<PatientMessagesPage> createState() => _PatientMessagesPageState();
}

class _PatientMessagesPageState extends State<PatientMessagesPage> {
  List<dynamic> messages = [];

  Future<void> fetchMessages() async {
    final url = Uri.parse('http://10.0.2.2:5000/api/messages/received/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        messages = jsonDecode(response.body);
      });
    } else {
      // Handle error
      print('Erreur lors du chargement des messages');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: messages.isEmpty
          ? const Center(child: Text('📩 Vous n\'avez reçu aucun message.'))
          : ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[index];
          return ListTile(
            title: Text(msg['senderId']['name'] ?? 'Thérapeute'),
            subtitle: Text(msg['content']),
            trailing: Text(DateTime.parse(msg['timestamp']).toLocal().toString().substring(0, 16)),
          );
        },
      ),
    );
  }
}
