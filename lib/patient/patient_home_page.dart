import 'package:flutter/material.dart';
import 'package:application_parcours_d_exil/hamburger_menu.dart';

class PatientHomePage extends StatefulWidget {
  final String id; // l'identifiant du patient connecté

  const PatientHomePage({Key? key, required this.id}) : super(key: key);

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Center(child: Text("Accueil Patient")), // Page d'accueil
    Center(child: Text("Programme")),       // À compléter
    Center(child: Text("Messages")),        // À compléter
    Center(child: Text("Mon compte")),      // À compléter
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: HamburgerMenu(),
      appBar: AppBar(automaticallyImplyLeading: false,
          title: const Text('Accueil Patient')),
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Programme'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Compte'),
        ],
      ),
    );
  }
}


