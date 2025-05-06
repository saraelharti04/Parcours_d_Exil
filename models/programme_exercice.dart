import 'package:uuid/uuid.dart';

class ProgrammeExercice {
  final String id;
  final String utilisateurId;
  final String therapeuteId;
  final String titre;
  final String description;
  final DateTime dateCreation;

  ProgrammeExercice({
    String? id,
    required this.utilisateurId,
    required this.therapeuteId,
    required this.titre,
    required this.description,
    required this.dateCreation,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'utilisateur_id': utilisateurId,
      'therapeute_id': therapeuteId,
      'titre': titre,
      'description': description,
      'date_creation': dateCreation.toIso8601String(),
    };
  }

  factory ProgrammeExercice.fromMap(Map<String, dynamic> map) {
    return ProgrammeExercice(
      id: map['id'],
      utilisateurId: map['utilisateur_id'],
      therapeuteId: map['therapeute_id'],
      titre: map['titre'],
      description: map['description'],
      dateCreation: DateTime.parse(map['date_creation']),
    );
  }
}
6. Modèle Exercice
Copier
import 'package:uuid/uuid.dart';

class Exercice {
  final String id;
  final String programmeId;
  final String nom;
  final int duree;
  final int repetitions;
  final int ordre;

  Exercice({
    String? id,
    required this.programmeId,
    required this.nom,
    required this.duree,
    required this.repetitions,
    required this.ordre,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'programme_id': programmeId,
      'nom': nom,
      'duree': duree,
      'repetitions': repetitions,
      'ordre': ordre,
    };
  }

  factory Exercice.fromMap(Map<String, dynamic> map) {
    return Exercice(
      id: map['id'],
      programmeId: map['programme_id'],
      nom: map['nom'],
      duree: map['duree'],
      repetitions: map['repetitions'],
      ordre: map['ordre'],
    );
  }
}