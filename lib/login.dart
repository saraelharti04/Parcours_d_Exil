import 'package:flutter/material.dart';
import 'package:application_parcours_d_exil/home.dart';
import 'package:application_parcours_d_exil/patient/patient_connexion.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf4f4f4),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bienvenue sur Parcours d\'Exil',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PatientConnexionPage()),
                );
              },
              child: const Text('Se connecter'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Home(isTherapist: true, isPatient: false),
                  ),
                );
              },
              child: const Text('Thérapeute'),
            ),
          ],
        ),
      ),
    );
  }
}




