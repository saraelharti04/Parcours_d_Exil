import 'package:flutter/material.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  MessagesPageState createState() => MessagesPageState();
}

class MessagesPageState extends State<MessagesPage> {
  final TextEditingController _messageController = TextEditingController();
  String? _selectedPatient;
  final List<String> _patients = ["Patient 1", "Patient 2", "Patient 3"];
  final Map<String, List<String>> _messages = {}; // Historique des messages

  void _sendMessage() {
    if (_selectedPatient != null && _messageController.text.isNotEmpty) {
      setState(() {
        _messages[_selectedPatient!] = _messages[_selectedPatient!] ?? [];
        _messages[_selectedPatient!]!.add(_messageController.text);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Message envoyé à $_selectedPatient")),
      );
      _messageController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sélectionne un patient et écris un message.")),
      );
    }
  }

  void _startNewConversation() {
    showDialog(
      context: context,
      builder: (context) {
        String? _newPatient;
        return AlertDialog(
          title: const Text("Créer une nouvelle conversation"),
          content: DropdownButtonFormField<String>(
            hint: const Text("Sélectionner un patient"),
            items: _patients.map((patient) {
              return DropdownMenuItem(
                value: patient,
                child: Text(patient),
              );
            }).toList(),
            onChanged: (value) {
              _newPatient = value;
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_newPatient != null) {
                  setState(() {
                    _selectedPatient = _newPatient;
                    _messages[_selectedPatient!] = [];
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Créer"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _startNewConversation, // Bouton pour créer une nouvelle discussion
          ),
        ],
      ),
      body: Column(
        children: [
          // 🟢 Liste des patients avec qui on a parlé
          Expanded(
            child: ListView.builder(
              itemCount: _messages.keys.length,
              itemBuilder: (context, index) {
                String patient = _messages.keys.elementAt(index);
                return ListTile(
                  title: Text(patient),
                  subtitle: Text(
                    _messages[patient]!.isNotEmpty
                        ? _messages[patient]!.last
                        : "Aucun message",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    setState(() {
                      _selectedPatient = patient;
                    });
                  },
                );
              },
            ),
          ),
          // 🟢 Interface d’envoi de message
          if (_selectedPatient != null) ...[
            Divider(height: 1, thickness: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Discussion avec $_selectedPatient",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _messageController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Tape ton message ici...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send),
                      label: const Text("Envoyer"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}


