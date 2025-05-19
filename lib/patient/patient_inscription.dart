import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PatientInscriptionPage extends StatefulWidget {
  const PatientInscriptionPage({Key? key}) : super(key: key);

  @override
  _PatientInscriptionPageState createState() => _PatientInscriptionPageState();
}

class _PatientInscriptionPageState extends State<PatientInscriptionPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? selectedGenre;
  String _errorMessage = '';
  String _successMessage = '';

  Future<void> _createAccount() async {
    final id = _idController.text.trim();
    final password = _passwordController.text.trim();

    if (id.isEmpty || password.isEmpty || selectedGenre == null) {
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs.';
        _successMessage = '';
      });
      return;
    }

    final url = Uri.parse('http://10.0.2.2:5000/api/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': id,
          'password': password,
          'genre': selectedGenre,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _successMessage = 'Compte créé avec succès';
          _errorMessage = '';
        });
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pop(context);
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _errorMessage = data['message'] ?? 'Erreur lors de l’inscription';
          _successMessage = '';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion au serveur';
        _successMessage = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte Patient')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: const InputDecoration(labelText: 'Numéro identifiant'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedGenre,
              hint: const Text('Genre'),
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'Femme', child: Text('Femme')),
                DropdownMenuItem(value: 'Homme', child: Text('Homme')),
                DropdownMenuItem(value: 'Autre', child: Text('Je préfère me définir autrement')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedGenre = value;
                });
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _createAccount,
              child: const Text('Créer le compte'),
            ),
            const SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            if (_successMessage.isNotEmpty)
              Text(_successMessage, style: const TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}



