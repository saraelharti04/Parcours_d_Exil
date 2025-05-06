class Therapeute {
  final String id;
  final String motDePasse;

  Therapeute({required this.id, required this.motDePasse});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'motDePasse': motDePasse,
    };
  }

  factory Therapeute.fromMap(Map<String, dynamic> map) {
    return Therapeute(
      id: map['id'],
      motDePasse: map['motDePasse'],
    );
  }
}
