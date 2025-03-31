import 'package:uuid/uuid.dart';

class RappelOrdonnance {
  final String id;
  final String utilisateurId;
  final String ordonnanceId;
  final DateTime dateHeure;

  RappelOrdonnance({
    String? id,
    required this.utilisateurId,
    required this.ordonnanceId,
    required this.dateHeure,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'utilisateur_id': utilisateurId,
      'ordonnance_id': ordonnanceId,
      'date_heure': dateHeure.toIso8601String(),
    };
  }

  factory RappelOrdonnance.fromMap(Map<String, dynamic> map) {
    return RappelOrdonnance(
      id: map['id'],
      utilisateurId: map['utilisateur_id'],
      ordonnanceId: map['ordonnance_id'],
      dateHeure: DateTime.parse(map['date_heure']),
    );
  }
}