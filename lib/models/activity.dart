import 'package:uuid/uuid.dart';

class Activite {
  final String id;
  final String titre;
  final String description;
  final DateTime dateHeure;
  final String type;

  Activite({
    String? id,
    required this.titre,
    required this.description,
    required this.dateHeure,
    required this.type,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'date_heure': dateHeure.toIso8601String(),
      'type': type,
    };
  }

  factory Activite.fromMap(Map<String, dynamic> map) {
    return Activite(
      id: map['id'],
      titre: map['titre'],
      description: map['description'],
      dateHeure: DateTime.parse(map['date_heure']),
      type: map['type'],
    );
  }
}