import 'package:uuid/uuid.dart';

class Utilisateur {
  final String id;
  final String numeroIpp;
  final String motDePasse;
  final DateTime dateInscription;

  Utilisateur({
    String? id,
    required this.numeroIpp,
    required this.motDePasse,
    required this.dateInscription,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero_ipp': numeroIpp,
      'mot_de_passe': motDePasse,
      'date_inscription': dateInscription.toIso8601String(),
    };
  }

  factory Utilisateur.fromMap(Map<String, dynamic> map) {
    return Utilisateur(
      id: map['id'],
      numeroIpp: map['numero_ipp'],
      motDePasse: map['mot_de_passe'],
      dateInscription: DateTime.parse(map['date_inscription']),
    );
  }
}