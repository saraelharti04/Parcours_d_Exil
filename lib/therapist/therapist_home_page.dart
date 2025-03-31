import 'package:flutter/material.dart';
import '../hamburger_menu.dart';

class TherapistHomePage extends StatelessWidget {
  const TherapistHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: HamburgerMenu(),
      body: SafeArea(
        child: Center(
          child: Text(
            "Bienvenue sur l'accueil thérapeute",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
