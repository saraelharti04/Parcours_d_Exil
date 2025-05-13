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
  String? _selectedPatientId;
  final Map<String, List<String>> _messages = {};
  List<Map<String, String>> _patients = [];
  bool _isLoadingPatients = true;

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/users'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('📦 Utilisateurs récupérés : $data'); // 👈 AJOUT ICI

        final patients = data
            .where((user) => user['type'] == 'patient')
            .map<Map<String, String>>((user) => {
          'id': user['_id'],
          'name': user['username'] ?? user['email'] ?? 'Inconnu',
        })
            .toList();


        setState(() {
          _patients = patients;
          _isLoadingPatients = false;
        });
      } else {
        throw Exception('Erreur lors du chargement des patients');
      }
    } catch (e) {
      print('Erreur lors du chargement des patients : $e');
      setState(() {
        _isLoadingPatients = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (_selectedPatientId != null && message.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:5000/api/messages'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'senderId': widget.therapistId,
            'receiverId': _selectedPatientId,
            'content': message,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
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
      appBar: AppBar(title: const Text('Messagerie Thérapeute')),
      body: _isLoadingPatients
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Sélectionner un patient'),
              value: _selectedPatientId,
              items: _patients.map((patient) {
                return DropdownMenuItem<String>(
                  value: patient['id'],
                  child: Text(patient['name'] ?? 'Sans nom'),
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
