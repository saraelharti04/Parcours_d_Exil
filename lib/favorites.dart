import 'package:flutter/material.dart';
import 'home.dart';
import 'hamburger_menu.dart';
import 'package:url_launcher/url_launcher.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Toggle Favorite and Save
  void toggleFavorite(Content content) {
    setState(() {
      if (favoriteContents.contains(content)) {
        favoriteContents.remove(content);
      } else {
        favoriteContents.add(content);
      }
      saveFavorites(); // Save the updated favorites list
    });
  }

  @override
  Widget build(BuildContext context) {
    const colors = [
      Color(0xFFC4F6C9),
      Color(0xFFC1EAF3),
      Color(0xFFC8CDEA),
      Color(0xFFF7ED90),
      Color(0xFFEBC1C2)
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: HamburgerMenu(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 20), // Height of the AppBar + padding
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0), // Padding above the AppBar content
          child: AppBar(
            title: const Text('Favoris'),
            actions: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: favoriteContents.length,
                itemBuilder: (context, index) {
                  final content = favoriteContents[index];
                  final color = colors[index % colors.length];

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(vertical: 5.0),
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          blurRadius: 6.0,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Row(
                        children: [
                          // Media Type Icon on the left
                          _getMediaTypeIcon(content.type),

                          const SizedBox(width: 10), // Adding space between the icon and title

                          // Title left-aligned with some padding
                          Expanded(
                            child: Text(
                              content.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                          ),

                          // Delete Icon on the right
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.black),
                            onPressed: () {
                              toggleFavorite(content); // Call the updated toggle function
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        if (content.type == "map") {
                          launchUrl(Uri.parse(content.filePath)); // Open Google Maps link
                        } else if (content.type == "pdf") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PDFViewerPage(
                                content: content,  // Pass the entire Content object
                                pdfLink: content.pdfLink,  
                                pdfLinkText: content.pdfLinkText, 
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayerPage(content: content),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getMediaTypeIcon(String type) {
    switch (type) {
      case 'audio':
        return const Icon(Icons.audiotrack, size: 24.0);
      case 'video':
        return const Icon(Icons.videocam, size: 24.0);
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, size: 24.0);
      case 'map':
        return const Icon(Icons.pin_drop, size: 24.0); // Map icon for map types
      default:
        return const Icon(Icons.help, size: 24.0); // Default icon if no type matches
    }
  }
}
