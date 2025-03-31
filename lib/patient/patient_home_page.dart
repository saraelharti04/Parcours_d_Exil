import 'package:flutter/material.dart';
import 'package:application_parcours_d_exil/hamburger_menu.dart';

class PatientHomePage extends StatelessWidget {
  const PatientHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: HamburgerMenu(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            children: const [
              Card(child: Center(child: Text("Accueil Patient 1"))),
              Card(child: Center(child: Text("Accueil Patient 2"))),
            ],
          ),
        ),
      ),
    );
  }
}

