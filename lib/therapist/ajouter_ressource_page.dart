import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart' as p;
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:http/http.dart' as http;

import '../appwrite_client.dart'; // Fichier de configuration Appwrite
import '../models/ressource.dart';
import '../database/ressource_dao.dart';
import '../constants/categories.dart';

class AjouterRessourcePage extends StatefulWidget {
  const AjouterRessourcePage({super.key});

  @override
  State<AjouterRessourcePage> createState() => _AjouterRessourcePageState();
}

class _AjouterRessourcePageState extends State<AjouterRessourcePage> {
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  String? selectedCategorie;
  String? selectedSousCategorie;
  String? fichierPath;
  String? audioFRPath;
  String? audioENPath;
  String? imagePath;

  late RessourceDao _dao;
  final AppwriteClient appwriteClient = AppwriteClient();

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  Future<void> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'parcours_exil.db');
    final db = await databaseFactoryIo.openDatabase(dbPath);
    _dao = RessourceDao(db);
  }

  Future<void> envoyerVersMongoDB(Ressource ressource) async {
    final url = Uri.parse('https://parcours-d-exil.onrender.com/api/ressources/add_ressource');

    final body = {
      'id': ressource.id,
      'categorie': ressource.categorie,
      'sousCategorie': ressource.sousCategorie,
      'titre': ressource.titre,
      'type': ressource.type,
      'fichier': ressource.fichier,
      'audioFR': ressource.audioFR,
      'audioEN': ressource.audioEN,
      'image': ressource.image,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Ressource envoyée à MongoDB avec succès.');
      } else {
        print('Erreur lors de l\'envoi à MongoDB: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print('Exception lors de l\'envoi à MongoDB: $e');
    }
  }

  Future<Map<String, String>> _envoyerRessourceAuServeur() async {
    final uploadedIds = <String, String>{};
    const bucketId = '6825cfaf00103670137a';

    try {
      Future<String> upload(String label, String? path) async {
        if (path == null) return '';
        final file = File(path);
        final response = await appwriteClient.storage.createFile(
          bucketId: bucketId,
          fileId: ID.unique(),
          file: InputFile.fromPath(path: file.path),
        );
        print('$label uploaded: ${response.$id}');
        return response.$id;
      }

      uploadedIds['fichier'] = await upload('Fichier principal', fichierPath);
      uploadedIds['audioFR'] = await upload('Audio FR', audioFRPath);
      uploadedIds['audioEN'] = await upload('Audio EN', audioENPath);
      uploadedIds['image'] = await upload('Image', imagePath);
    } catch (e) {
      print('Erreur lors de l\'upload Appwrite: $e');
    }

    return uploadedIds;
  }

  Future<void> _ajouterRessource() async {
    if (selectedCategorie == null || selectedSousCategorie == null || fichierPath == null) return;

    final uploadedRefs = await _envoyerRessourceAuServeur();

    final ressource = Ressource(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titre: _titreController.text,
      type: _typeController.text,
      fichier: uploadedRefs['fichier'] ?? '',
      audioFR: uploadedRefs['audioFR'] ?? '',
      audioEN: uploadedRefs['audioEN'] ?? '',
      image: uploadedRefs['image'] ?? '',
      categorie: selectedCategorie!,
      sousCategorie: selectedSousCategorie!,
    );

    await envoyerVersMongoDB(ressource);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ressource ajoutée avec succès')),
    );
    Navigator.pop(context);
  }

  Future<void> _pickFile(Function(String path) onSelected) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      onSelected(result.files.single.path!);
    }
  }

  Widget _buildFilePicker(String label, String? currentPath, Function(String path) onPicked) {
    return Row(
      children: [
        Expanded(child: Text(currentPath ?? "Aucun fichier sélectionné")),
        TextButton(
          onPressed: () => _pickFile(onPicked),
          child: Text("Parcourir ($label)"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: const Text('Ajouter une ressource')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButton<String>(
                value: selectedCategorie,
                hint: const Text('Choisir une catégorie'),
                isExpanded: true,
                items: categories.map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                )).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedCategorie = val;
                    selectedSousCategorie = null;
                  });
                },
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedSousCategorie,
                hint: const Text('Choisir une sous-catégorie'),
                isExpanded: true,
                items: selectedCategorie == null ? [] :
                sousCategories[selectedCategorie!]!.map((sousCat) => DropdownMenuItem(
                  value: sousCat,
                  child: Text(sousCat),
                )).toList(),
                onChanged: (val) => setState(() => selectedSousCategorie = val),
              ),
              TextField(controller: _titreController, decoration: const InputDecoration(labelText: 'Titre')),
              TextField(controller: _typeController, decoration: const InputDecoration(labelText: 'Type (pdf, audio, video)')),
              const SizedBox(height: 10),
              _buildFilePicker("Fichier principal", fichierPath, (path) => setState(() => fichierPath = path)),
              _buildFilePicker("Audio FR (optionnel)", audioFRPath, (path) => setState(() => audioFRPath = path)),
              _buildFilePicker("Audio EN (optionnel)", audioENPath, (path) => setState(() => audioENPath = path)),
              _buildFilePicker("Image de couverture (optionnel)", imagePath, (path) => setState(() => imagePath = path)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _ajouterRessource,
                child: const Text('Ajouter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
