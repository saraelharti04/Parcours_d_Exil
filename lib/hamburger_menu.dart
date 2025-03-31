import 'package:flutter/material.dart';
import 'package:application_parcours_d_exil/home.dart';
import 'package:application_parcours_d_exil/favorites.dart';
import 'package:application_parcours_d_exil/settings.dart';

class HamburgerMenu extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems = [
    {"title": "Home", "image": "assets/icons/home.png"},
    {
      "title": "Parcours de Soins",
      "image": "assets/icons/parcoursSoins.png",
      "menuItem": mainMenu.firstWhere((item) => item.title == "Parcours de Soins"),
    },
    {
      "title": "Mes Besoins",
      "image": "assets/icons/mesBesoins.png",
      "menuItem": mainMenu.firstWhere((item) => item.title == "Mes Besoins"),
    },
    {
      "title": "Me sentir mieux",
      "image": "assets/icons/santementale.png",
      "menuItem": mainMenu.firstWhere((item) => item.title == "Me sentir mieux"),
    },
    {
      "title": "Calmer mes Douleurs",
      "image": "assets/icons/corporel.png",
      "menuItem": mainMenu.firstWhere((item) => item.title == "Calmer mes Douleurs"),
    },
    {
      "title": "Mieux Comprendre",
      "image": "assets/icons/psychoEducation.png",
      "menuItem": mainMenu.firstWhere((item) => item.title == "Mieux Comprendre"),
    },
    {
      "title": "Aide au Quotidien",
      "image": "assets/icons/aideAuQuotidien.png",
      "menuItem": mainMenu.firstWhere((item) => item.title == "Aide au Quotidien"),
    },
    {
      "title": "Urgences",
      "image": "assets/icons/urgences.png",
      "menuItem": mainMenu.firstWhere((item) => item.title == "Urgences"),
    },
    {"title": "Favoris", "image": "assets/icons/favorite.png"},
    {"title": "Settings", "image": "assets/icons/settings.png"},
  ];

  HamburgerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding:  EdgeInsets.only(top: 30.0, left: 16.0), // Added top padding here
              child: Text(
                "Menu",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final menuItem = menuItems[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(menuItem["image"]!),
                      radius: 20,
                    ),
                    title: Text(
                      menuItem["title"]!,
                      style: const TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer

                      // Navigation logic for submenus and pages
                      if (menuItem["title"] == "Home") {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Home(isTherapist: false, isPatient: true),
                          ),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Home(isTherapist: true, isPatient: false),
                          ),
                        );
                      } else if (menuItem["title"] == "Favoris") {
                        Navigator.pushReplacement(
                          context, 
                          MaterialPageRoute(builder: (context) => const FavoritesPage()),
                        );
                      } else if (menuItem["title"] == "Settings") {
                        Navigator.pushReplacement(
                          context, 
                          MaterialPageRoute(builder: (context) => SettingsPage()),
                        );
                      } else if (menuItem.containsKey("menuItem")) {
                        final selectedMenuItem = menuItem["menuItem"] as MenuItem;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MenuPage(
                              title: selectedMenuItem.title,
                              menuItems: selectedMenuItem.subMenus ?? [],
                              content: selectedMenuItem.content ?? [],
                            ),
                          ),
                        );
                      } else {
                        // Handle undefined menu items
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "No route defined for ${menuItem["title"]}",
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

