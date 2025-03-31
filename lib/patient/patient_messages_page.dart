import 'package:flutter/material.dart';

class PatientMessagesPage extends StatelessWidget {
  const PatientMessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          '📩 Vous n\'avez reçu aucun message pour le moment.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}