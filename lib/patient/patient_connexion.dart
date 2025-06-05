import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../home.dart';
import 'patient_inscription.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientConnexionPage extends StatefulWidget {
  const PatientConnexionPage({Key? key}) : super(key: key);

  @override
  State<PatientConnexionPage> createState() => _PatientConnexionPageState();
}

class _PatientConnexionPageState extends State<PatientConnexionPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isTherapist = false;
  String _errorMessage = '';

  Future<void> _login() async {
    final String username = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String type = _isTherapist ? 'thérapeute' : 'patient';

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs';
      });
      return;
    }

    final url = Uri.parse('https://parcours-d-exil.onrender.com/api/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'type': type,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final type = data['type'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_type', type);
        await prefs.setString('user_id', data['user']['id']); // <-- AJOUT ICI
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Home(
              isTherapist: type == 'thérapeute',
              isPatient: type == 'patient',
              isLoggedIn: true
            ),
          ),
        );
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _errorMessage = data['message'] ?? 'Erreur inconnue';
        });
      }
    } catch (e) {
      print('Erreur capturée côté Flutter : $e');
      setState(() {
        _errorMessage = 'Erreur de connexion au serveur';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Identifiant'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Se connecter'),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 20),
            if (!_isTherapist)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PatientInscriptionPage()),
                  );
                },
                child: const Text("Tu n’as pas encore de compte ? Créer un compte"),
              ),
          ],
        ),
      ),
    );
  }
}



