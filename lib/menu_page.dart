import 'package:flutter/material.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../database/ressource_dao.dart';
import '../models/ressource.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:application_parcours_d_exil/models/menu_item.dart';



class MenuPage extends StatefulWidget {
  final String title;
  final List<MenuItem> menuItems;
  final List<Content> content;

  const MenuPage({
    super.key,
    required this.title,
    this.menuItems = const [],
    this.content = const [],
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}


class _MenuPageState extends State<MenuPage> {
  Map<String, List<Ressource>> groupedBySubCategory = {};

  @override
  void initState() {
    super.initState();
    loadRessources();
  }

  Future<void> loadRessources() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'parcours_exil.db');
    final database = await databaseFactoryIo.openDatabase(dbPath);
    final dao = RessourceDao(database);

    final all = await dao.getAll();
    final filtered = all.where((r) => r.categorie == widget.title).toList();

    final map = <String, List<Ressource>>{};
    for (var r in filtered) {
      map.putIfAbsent(r.sousCategorie, () => []).add(r);
    }

    setState(() {
      groupedBySubCategory = map;
    });
  }

  void openRessource(Ressource r) {
    if (r.fichier.isNotEmpty) {
      onTap: () {
        if (r.type == 'pdf') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PDFViewerPage(path: r.fichier)),
          );
        } else if (r.type == 'video') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VideoPlayerPage(path: r.fichier)),
          );
        } else if (r.type == 'audio') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AudioPlayerPage(path: r.fichier)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Type non supporté')),
          );
        }
      };

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fichier introuvable.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,
          title: Text(widget.title)),
      body: groupedBySubCategory.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: groupedBySubCategory.entries.map((entry) {
          return ExpansionTile(
            title: Text(entry.key),
            children: entry.value.map((r) {
              return ListTile(
                leading: Icon(_getIconForType(r.type)),
                title: Text(r.titre),
                onTap: () => openRessource(r),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'audio':
        return Icons.audiotrack;
      case 'video':
        return Icons.videocam;
      default:
        return Icons.insert_drive_file;
    }
  }
}

// PDF Viewer
class PDFViewerPage extends StatelessWidget {
  final String path;

  const PDFViewerPage({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,
          title: const Text("PDF")),
      body: PDFView(filePath: path),
    );
  }
}

// Video Player
class VideoPlayerPage extends StatefulWidget {
  final String path;

  const VideoPlayerPage({super.key, required this.path});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.path)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,
          title: const Text("Vidéo")),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        )
            : const CircularProgressIndicator(),
      ),
    );
  }
}

// Audio Player
class AudioPlayerPage extends StatefulWidget {
  final String path;

  const AudioPlayerPage({super.key, required this.path});

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _player.setAsset(widget.path);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,
          title: const Text("Audio")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () => _player.play(),
              iconSize: 64,
            ),
            IconButton(
              icon: const Icon(Icons.pause),
              onPressed: () => _player.pause(),
              iconSize: 64,
            ),
          ],
        ),
      ),
    );
  }
}

