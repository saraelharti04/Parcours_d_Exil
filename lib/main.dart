import 'package:flutter/material.dart';
import 'package:application_parcours_d_exil/home.dart'; // ou home.dart si tu l’as renommé
import 'database/app_database.dart';
import 'login.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:shared_preferences/shared_preferences.dart';



void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase().init(); // ← Initialise la base de donnée
  final session = await AudioSession.instance;
  await session.configure(AudioSessionConfiguration.music());
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  final userId = prefs.getString('user_id');

  // On détermine si l'utilisateur est connecté
  final isLoggedIn = token != null && token.isNotEmpty && userId != null;

  final userType = prefs.getString('user_type');

  // On peut aussi différencier les rôles (optionnel si tu l'enregistres)
  final isTherapist = prefs.getString('user_type') == 'thérapeute';
  final isPatient = prefs.getString('user_type') == 'patient';
  print(isLoggedIn);
  runApp(MyApp(isLoggedIn: isLoggedIn,
    isTherapist: isTherapist,
    isPatient: isPatient, token: token, userId: userId,));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final bool isTherapist;
  final bool isPatient;
  final String? userId;
  final String? token;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    required this.isTherapist,
    required this.isPatient,
    required this.userId,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Parcours d\'Exil',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: isLoggedIn
          ? Home(isLoggedIn: isLoggedIn, isTherapist: isTherapist, isPatient: isPatient, token: token, userId: userId)
          : const LoginPage(),
    );
  }
}