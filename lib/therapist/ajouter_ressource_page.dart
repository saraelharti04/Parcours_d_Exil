import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart' as p;
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

  Future<void> _pickFile(Function(String path) onSelected) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      onSelected(result.files.single.path!);
    }
  }

  Future<void> _ajouterRessource() async {
    if (selectedCategorie == null || selectedSousCategorie == null || fichierPath == null) return;

    final ressource = Ressource(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titre: _titreController.text,
      type: _typeController.text,
      fichier: fichierPath!,
      audioFR: audioFRPath ?? '',
      audioEN: audioENPath ?? '',
      image: imagePath ?? '',
      categorie: selectedCategorie!,
      sousCategorie: selectedSousCategorie!,
    );

    await _dao.insert(ressource);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ressource ajoutée avec succès')),
    );
    Navigator.pop(context);
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
      appBar: AppBar(title: const Text('Ajouter une ressource')),
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



