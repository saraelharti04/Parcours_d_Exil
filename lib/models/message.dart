class Message {
  final String id;
  final String idTherapeute;
  final String idPatient;
  final String contenu;
  final DateTime date;

  Message({
    required this.id,
    required this.idTherapeute,
    required this.idPatient,
    required this.contenu,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idTherapeute': idTherapeute,
      'idPatient': idPatient,
      'contenu': contenu,
      'date': date.toIso8601String(),
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      idTherapeute: map['idTherapeute'],
      idPatient: map['idPatient'],
      contenu: map['contenu'],
      date: DateTime.parse(map['date']),
    );
  }
}
