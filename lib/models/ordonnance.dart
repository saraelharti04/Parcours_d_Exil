import 'package:uuid/uuid.dart';

class Ordonnance {
  final String id;
  final String utilisateurId;
  final String therapeuteId;
  final String medicament;
  final String posologie;
  final DateTime datePrescription;

  Ordonnance({
    String? id,
    required this.utilisateurId,
    required this.therapeuteId,
    required this.medicament,
    required this.posologie,
    required this.datePrescription,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'utilisateur_id': utilisateurId,
      'therapeute_id': therapeuteId,
      'medicament': medicament,
      'posologie': posologie,
      'date_prescription': datePrescription.toIso8601String(),
    };
  }

  factory Ordonnance.fromMap(Map<String, dynamic> map) {
    return Ordonnance(
      id: map['id'],
      utilisateurId: map['utilisateur_id'],
      therapeuteId: map['therapeute_id'],
      medicament: map['medicament'],
      posologie: map['posologie'],
      datePrescription: DateTime.parse(map['date_prescription']),
    );
  }
}