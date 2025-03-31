import 'package:flutter/material.dart';
import 'package:application_parcours_d_exil/home.dart'; // ou home.dart si tu l’as renommé

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Parcours d\'Exil',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Home(isTherapist: false, isPatient: false),
    );
  }
}


