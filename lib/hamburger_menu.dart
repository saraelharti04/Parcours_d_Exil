import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

import 'models/ressource.dart';
import 'database/ressource_dao.dart';
import 'package:application_parcours_d_exil/home.dart' hide MenuPage, MenuItem, Content;
import 'menu_page.dart';
import 'favorites.dart';
import 'settings.dart';
import 'package:application_parcours_d_exil/models/menu_item.dart';


class HamburgerMenu extends StatefulWidget {
  const HamburgerMenu({Key? key}) : super(key: key);

  @override
  State<HamburgerMenu> createState() => _HamburgerMenuState();
}

class _HamburgerMenuState extends State<HamburgerMenu> {
  late Future<List<Map<String, dynamic>>> menuItemsFuture;

  @override
  void initState() {
    super.initState();
    menuItemsFuture = _loadMenuItems();
  }

  Future<List<Map<String, dynamic>>> _loadMenuItems() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, 'parcours_exil.db');
    final database = await databaseFactoryIo.openDatabase(dbPath);
    final dao = RessourceDao(database);
    final ressources = await dao.getAll();

    final categories = ressources.fold<Map<String, Map<String, List<Ressource>>>>({}, (acc, res) {
      acc[res.categorie] ??= {};
      acc[res.categorie]![res.sousCategorie] ??= [];
      acc[res.categorie]![res.sousCategorie]!.add(res);
      return acc;
    });

    final List<Map<String, dynamic>> menuItems = [
      {"title": "Home", "image": "assets/icons/home.png"},
      {"title": "Favoris", "image": "assets/icons/favorite.png"},
      {"title": "Settings", "image": "assets/icons/settings.png"},
    ];

    categories.forEach((cat, subMap) {
      menuItems.insert(
        1,
        {
          "title": cat,
          "image": "assets/icons/${cat.toLowerCase().replaceAll(" ", "")}.png",
          "menuItem": MenuItem(
            title: cat,
            subMenus: subMap.entries.map((entry) {
              return MenuItem(
                title: entry.key,
                content: entry.value.map((res) => Content(
                  title: res.titre,
                  type: res.type,
                  filePath: res.fichier,
                  audioPathFR: res.audioFR,
                  audioPathEN: res.audioEN,
                  coverImagePath: res.image,
                )).toList(),
              );
            }).toList(),
          )
        },
      );
    });

    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: menuItemsFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final menuItems = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 30.0, left: 16.0),
                  child: Text(
                    "Menu",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
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
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        onTap: () {
                          Navigator.pop(context);

                          if (menuItem["title"] == "Home") {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const Home(isTherapist: false, isPatient: true)),
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
                            final selected = menuItem["menuItem"] as MenuItem;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MenuPage(
                                  title: selected.title,
                                  menuItems: (selected.subMenus ?? []).cast<MenuItem>(),
                                  content: (selected.content ?? []).cast<Content>(),
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
            );
          },
        ),
      ),
    );
  }
}



