import 'package:flutter/material.dart';
import 'package:application_parcours_d_exil/models/utilisateur.dart';
import 'package:application_parcours_d_exil/database/user_dao.dart'; // adapte selon ton chemin
import 'package:application_parcours_d_exil/database/app_database.dart'; // adapte selon ton chemin

class PatientInscriptionPage extends StatefulWidget {
  const PatientInscriptionPage({super.key});

  @override
  State<PatientInscriptionPage> createState() => _PatientInscriptionPageState();
}

class _PatientInscriptionPageState extends State<PatientInscriptionPage> {
  final _formKey = GlobalKey<FormState>();
  final _ippController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  void _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final db = await $FloorAppDatabase.databaseBuilder('parcours_exil.db').build();
      final utilisateurDao = UtilisateurDao(db);

      final newUser = Utilisateur(
        numeroIpp: _ippController.text,
        motDePasse: _passwordController.text,
        dateInscription: DateTime.now(),
      );

      await utilisateurDao.insert(newUser);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Compte créé avec succès")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _error = "Erreur : ${e.toString()}";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer un compte")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _ippController,
                decoration: const InputDecoration(labelText: "Numéro IPP"),
                validator: (value) => value == null || value.isEmpty ? "Champ requis" : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Mot de passe (4 chiffres)"),
                obscureText: true,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.length != 4) return "4 chiffres requis";
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _createAccount,
                child: const Text("Créer le compte"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
