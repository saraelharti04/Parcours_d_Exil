import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MessagesPage extends StatefulWidget {
  final String therapistId;

  const MessagesPage({super.key, required this.therapistId});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _messageController = TextEditingController();
  String? _selectedPatientId;
  final Map<String, List<String>> _messages = {};
  List<Map<String, String>> _patients = [];
  bool _loadingPatients = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5000/users/patients'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _patients = data
              .map((patient) => {
            'id': patient['_id'],
            'name': patient['name'] ?? 'Sans nom',
          })
              .toList();
          _loadingPatients = false;
        });
      } else {
        setState(() {
          _error = 'Erreur de récupération des patients.';
          _loadingPatients = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur de connexion à l\'API : $e';
        _loadingPatients = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (_selectedPatientId != null && message.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/messages/send'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'receiverId': _selectedPatientId,
            'content': message,
          }),
        );

        if (response.statusCode == 201) {
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
        const SnackBar(content: Text("Sélectionnez un patient et écrivez un message.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messagerie Thérapeute')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loadingPatients
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text(_error!))
            : Column(
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
