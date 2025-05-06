class Activite {
  final String id;
  final String nom;
  final String descriptif;
  final String jour;
  final String heure;

  Activite({
    required this.id,
    required this.nom,
    required this.descriptif,
    required this.jour,
    required this.heure,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'descriptif': descriptif,
      'jour': jour,
      'heure': heure,
    };
  }

  factory Activite.fromMap(Map<String, dynamic> map) {
    return Activite(
      id: map['id'],
      nom: map['nom'],
      descriptif: map['descriptif'],
      jour: map['jour'],
      heure: map['heure'],
    );
  }
}
