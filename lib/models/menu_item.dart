import 'package:application_parcours_d_exil/models/ressource.dart';

class Content {
  final String title;
  final String type; // "pdf", "audio", "video"
  final String filePath;
  final String? imagePath;
  final String? audioPathFR;
  final String? audioPathEN;
  final String? coverImagePath;

  Content({
    required this.title,
    required this.type,
    required this.filePath,
    this.imagePath,
    this.audioPathFR,
    this.audioPathEN,
    this.coverImagePath,
  });
}

class MenuItem {
  final String title;
  final String? imagePath; // <-- ajout ici
  final List<MenuItem>? subMenus;
  final List<Content>? content;

  MenuItem({
    required this.title,
    this.imagePath,
    this.subMenus,
    this.content,
  });
}

