import 'package:flutter/material.dart';

class PatientAccountPage extends StatelessWidget {
  const PatientAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          '👤 Mon compte (à venir)',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

