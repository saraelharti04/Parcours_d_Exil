import 'package:flutter/material.dart';
import 'package:application_parcours_d_exil/home.dart'; // ou home.dart si tu l’as renommé
import 'database/app_database.dart';
import 'login.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:audio_session/audio_session.dart';



void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase().init(); // ← Initialise la base de donnée
  final session = await AudioSession.instance;
  await session.configure(AudioSessionConfiguration.music());

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


