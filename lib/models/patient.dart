class Patient {
  final String id;
  final String motDePasse;
  final DateTime dateInscription;
  final String genre; // 👈 nouveau champ

  Patient({
    required this.id,
    required this.motDePasse,
    required this.dateInscription,
    required this.genre, // 👈
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mot_de_passe': motDePasse,
      'date_inscription': dateInscription.toIso8601String(),
      'genre': genre, // 👈
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      motDePasse: map['mot_de_passe'],
      dateInscription: DateTime.parse(map['date_inscription']),
      genre: map['genre'], // 👈
    );
  }
}

