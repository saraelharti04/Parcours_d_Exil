import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MessagesPage extends StatefulWidget {
  final String therapistId; // Identifiant du thérapeute

  const MessagesPage({super.key, required this.therapistId});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _messageController = TextEditingController();
  String? _selectedPatientId;
  final Map<String, List<String>> _messages = {};

  final List<Map<String, String>> _patients = [
    {'id': '1', 'name': 'Patient 1'},
    {'id': '2', 'name': 'Patient 2'},
    {'id': '3', 'name': 'Patient 3'},
  ];

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (_selectedPatientId != null && message.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/messages'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'senderId': widget.therapistId,
            'receiverId': _selectedPatientId,
            'content': message,
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            _messages[_selectedPatientId!] = _messages[_selectedPatientId!] ?? [];
            _messages[_selectedPatientId!]!.add(message);
            _messageController.clear();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Message envoyé à ${_selectedPatientId!}")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erreur lors de l'envoi du message.")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e")),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messagerie Thérapeute'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Sélectionner un patient',
              ),
              value: _selectedPatientId,
              items: _patients.map((patient) {
                return DropdownMenuItem<String>(
                  value: patient['id'],
                  child: Text(patient['name']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPatientId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: (_messages[_selectedPatientId] ?? [])
                    .map((msg) => ListTile(title: Text(msg)))
                    .toList(),
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
