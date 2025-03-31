import 'package:uuid/uuid.dart';

class RappelExercice {
  final String id;
  final String utilisateurId;
  final String exerciceId;
  final DateTime dateHeure;

  RappelExercice({
    String? id,
    required this.utilisateurId,
    required this.exerciceId,
    required this.dateHeure,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'utilisateur_id': utilisateurId,
      'exercice_id': exerciceId,
      'date_heure': dateHeure.toIso8601String(),
    };
  }

  factory RappelExercice.fromMap(Map<String, dynamic> map) {
    return RappelExercice(
      id: map['id'],
      utilisateurId: map['utilisateur_id'],
      exerciceId: map['exercice_id'],
      dateHeure: DateTime.parse(map['date_heure']),
    );
  }
}