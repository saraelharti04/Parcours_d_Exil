import 'package:flutter/material.dart';
import '../hamburger_menu.dart';
import 'ajouter_ressource_page.dart'; // <-- à créer juste après

class TherapistHomePage extends StatelessWidget {
  const TherapistHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Accueil Thérapeute",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AjouterRessourcePage()),
              );
            },
          ),
        ],
      ),
      drawer: HamburgerMenu(),
      body: const SafeArea(
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

