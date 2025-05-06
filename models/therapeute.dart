import 'package:uuid/uuid.dart';

class Therapeute {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String motDePasse;

  Therapeute({
    String? id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.motDePasse,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'mot_de_passe': motDePasse,
    };
  }

  factory Therapeute.fromMap(Map<String, dynamic> map) {
    return Therapeute(
      id: map['id'],
      nom: map['nom'],
      prenom: map['prenom'],
      email: map['email'],
      motDePasse: map['mot_de_passe'],
    );
  }
}