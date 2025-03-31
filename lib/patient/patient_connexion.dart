import 'package:flutter/material.dart';
import 'package:application_parcours_d_exil/home.dart';
import 'package:application_parcours_d_exil/database/app_database.dart';
import 'package:application_parcours_d_exil/database/user_dao.dart';
import 'package:application_parcours_d_exil/models/utilisateur.dart';

class PatientConnexionPage extends StatefulWidget {
  const PatientConnexionPage({super.key});

  @override
  State<PatientConnexionPage> createState() => _PatientConnexionPageState();
}

class _PatientConnexionPageState extends State<PatientConnexionPage> {
  final _formKey = GlobalKey<FormState>();
  final _ippController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final db = await $FloorAppDatabase.databaseBuilder('parcours_exil.db').build();
      final utilisateurDao = UtilisateurDao(db);

      final users = await utilisateurDao.getAll();
      final matchingUser = users.firstWhere(
            (user) =>
        user.numeroIpp == _ippController.text &&
            user.motDePasse == _passwordController.text,
        orElse: () => throw Exception("Identifiants invalides"),
      );

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Home(isTherapist: false, isPatient: true),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = "Identifiant ou mot de passe incorrect";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connexion patient")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _ippController,
                decoration: const InputDecoration(labelText: "Numéro IPP"),
                validator: (value) =>
                value == null || value.isEmpty ? "Champ requis" : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Mot de passe"),
                obscureText: true,
                keyboardType: TextInputType.number,
                validator: (value) =>
                value == null || value.length != 4 ? "4 chiffres requis" : null,
              ),
              const SizedBox(height: 20),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: _login,
                child: const Text("Se connecter"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
