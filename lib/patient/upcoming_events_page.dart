import 'package:flutter/material.dart';

class UpcomingEventsPage extends StatelessWidget {
  const UpcomingEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📅 Prochains événements Parcours d\'Exil',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('- 3 avril : Atelier cuisine (14h, salle 3)'),
            Text('- 7 avril : Sortie au parc de Sceaux'),
            Text('- 12 avril : Groupe de parole (en ligne)'),
            Text('- 20 avril : Concert solidaire 🎶'),
          ],
        ),
      ),
    );
  }
}
