class Ressource {
  final String id ;
  final String categorie;
  final String sousCategorie;
  final String titre;
  final String type; // "pdf", "audio", "video"
  final String fichier;
  final String? audioFR;
  final String? audioEN;
  final String? image;

  Ressource({
    required this.id,
    required this.categorie,
    required this.sousCategorie,
    required this.titre,
    required this.type,
    required this.fichier,
    this.audioFR,
    this.audioEN,
    this.image,
  });

  factory Ressource.fromMap(Map<String, dynamic> map) => Ressource(
    id: map['id'],
    categorie: map['categorie'],
    sousCategorie: map['sousCategorie'],
    titre: map['titre'],
    type: map['type'],
    fichier: map['fichier'],
    audioFR: map['audioFR'],
    audioEN: map['audioEN'],
    image: map['image'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'categorie': categorie,
    'sousCategorie': sousCategorie,
    'titre': titre,
    'type': type,
    'fichier': fichier,
    'audioFR': audioFR,
    'audioEN': audioEN,
    'image': image,
  };
}




