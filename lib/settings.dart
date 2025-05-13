import 'package:flutter/material.dart';
import 'hamburger_menu.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final List<Map<String, dynamic>> settingsOptions = [
    {
      "title": "Langues",
      "icon": Icons.language_outlined,
      "description": '''
Language options will be available soon. 
Stay tuned for updates!
      
Les options de langue seront bientôt disponibles.
Restez à l'écoute pour les mises à jour !
      '''
    },
    {
      "title": "Options Audio",
      "icon": Icons.audiotrack_outlined,
      "description": '''
Audio options will be available soon.
Stay tuned for updates!

Les options audio seront bientôt disponibles.
Restez à l'écoute pour les mises à jour !
      '''
    },
    {
      "title": "Paramètres utilisateur",
      "icon": Icons.person_outline,
      "description": '''
User settings will be available soon.
Stay tuned for updates!

Les paramètres utilisateur seront bientôt disponibles.
Restez à l'écoute pour les mises à jour !
      '''
    },
    {
      "title": "Mentions légales",
      "icon": Icons.gavel_outlined,
      "description": "Conformément aux dispositions des Articles 6-III et 19 de la Loi n°2004-575 du 21 juin 2004 pour la Confiance dans l’économie numérique, dite L.C.E.N., il est porté à la connaissance des utilisateurs, ci-après l’« Utilisateur », de l'application mobile Parcours d’Exil, ci-après l’« Application », les présentes mentions légales."
    },
    {
      "title": "Citations (Health / Santé)",
      "icon": Icons.library_books_outlined,
      "description": '''
<b>1/ Intérêt d’utiliser des appli pour la santé mentale – OMS – paragraphe 48</b>
Plan d'action global pour la santé mentale 2013-2030 [Comprehensive mental health action plan 2013-2030]. Genève, Organisation mondiale de la Santé, 2022. Licence : CC BY-NC-SA 3.0 IGO.
[Read the full document](https://iris.who.int/bitstream/handle/10665/361818/9789240056923-fre.pdf?sequence=1)

<b>2/ Efficacy of Self-Management Smartphone-Based Apps for Post-traumatic Stress Disorder Symptoms: A Systematic Review and Meta-Analysis</b>
Goreis Andreas, Felnhofer Anna, Kafka Johanna Xenia, Probst Thomas, Kothgassner Oswald D.
JOURNAL=Frontiers in Neuroscience, 14, 2020
[Read the full article](https://www.frontiersin.org/journals/neuroscience/articles/10.3389/fnins.2020.00003/full)

<b>3/ Phoenix Guidelines (Australia) for treatment for PTSD</b>
Dans ces recommandations de référence, la méditation pleine conscience, l’exercice physique et la psychoéducation font partie du traitement proposé.

<b>4/ Traitement par phase</b>
Ce que nous proposons dans l’appli est utile pour la première phase de stabilisation : ancrage, gestion du stress et émotionnelle.
Van der Hart, O., Brown, P. et Van der Kolk, B. (2021). Chapitre 12. Pierre Janet et le traitement du stress post-traumatique. Dans Craparo, G., Ortu, F. et Van der Hart, O. (dir.), Pierre Janet : trauma et dissociation Un nouveau contexte pour la psychothérapie, la psychanalyse et la psychotraumatologie. ( p. 203 -218 ). De Boeck Supérieur. 
[Read the full document](https://shs-cairn-info.acces.bibl.ulaval.ca/pierre-janet-trauma-et-dissociation--9782807336223-page-203?lang=fr)
      '''
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,
        title: const Text('Paramètres'),
        toolbarHeight: 80, // Add more height to the app bar
        flexibleSpace: const Padding(
          padding: EdgeInsets.only(top: 20.0), // Add padding to top of the app bar
        ),
      ),
      drawer: HamburgerMenu(),
      body: ListView.builder(
        itemCount: settingsOptions.length,
        itemBuilder: (context, index) {
          final option = settingsOptions[index];
          return ListTile(
            title: Text(
              option["title"],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Icon(
              option["icon"],
              color: Colors.grey[600],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsDetailPage(
                    title: option["title"],
                    description: option["title"] == "Mentions légales" 
                        ? _getLegalText() // Use legal text for Mention légale
                        : option["description"],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Function to return the full legal text with bold parts
  String _getLegalText() {
    return '''

<b>MENTIONS LÉGALES DE L'APPLICATION MOBILE</b>

Conformément aux dispositions des Articles 6-III et 19 de la Loi n°2004-575 du 21 juin 2004 pour la Confiance dans l’économie numérique, dite L.C.E.N., il est porté à la connaissance des utilisateurs, ci-après l’« Utilisateur », de l'application mobile Parcours d’Exil, ci-après l’« Application », les présentes mentions légales.
L’installation, la connexion et la navigation sur l’Application par l’Utilisateur impliquent l’acceptation intégrale et sans réserve des présentes mentions légales.
Les mentions légales sont accessibles à tout moment dans l'Application via la rubrique « Mentions légales ».

<b>L’ÉDITEUR</b>
L’édition de l’Application est assurée par Parcours d’Exil, association immatriculée au Registre du Commerce et des Sociétés de Paris sous le numéro 444 001 804, dont le siège social est situé au :
4 avenue Richerand, 75010 Paris
Numéro de téléphone : 01 45 33 33 74
Adresse e-mail : contact@parcours-exil.org

Le Directeur de la publication est Sabrina Bignier, ci-après l’« Éditeur ».

<b>ACCÈS À L’APPLICATION</b>
L’Application est accessible 7j/7 et 24h/24, sauf en cas de force majeure, d’interruption programmée ou non, notamment pour des besoins de maintenance ou de mise à jour.
En cas de modification, interruption ou suspension de l’Application, l’Éditeur ne saurait être tenu responsable.

<b>COLLECTE DES DONNÉES</b>
Conformément à la loi Informatique et Libertés du 6 janvier 1978, l’Utilisateur dispose d’un droit d’accès, de rectification, de suppression et d’opposition concernant ses données personnelles. L’Utilisateur peut exercer ce droit via l’adresse e-mail : contact@parcours-exil.org

<b>PROPRIÉTÉ INTELLECTUELLE</b>
Toute utilisation, reproduction, diffusion, commercialisation ou modification de tout ou partie de l’Application, sans autorisation de l’Éditeur, est strictement interdite. Cela pourrait entraîner des actions et poursuites judiciaires telles que prévues par le Code de la propriété intellectuelle et le Code civil.

<b>Mise à jour :</b> le 10 décembre 2024 à Paris, France
''';
  }
}

class SettingsDetailPage extends StatelessWidget {
  final String title;
  final String description;

  const SettingsDetailPage({
    required this.title,
    required this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,

        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(  // Added SingleChildScrollView to allow scrolling for long texts
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black,
              ),
              children: _getTextSpans(description),  // This method will split and format the bold text
            ),
          ),
        ),
      ),
    );
  }

  List<TextSpan> _getTextSpans(String text) {
    final regex = RegExp(r'<b>(.*?)</b>', multiLine: true);
    final matches = regex.allMatches(text);
    List<TextSpan> textSpans = [];
    int lastIndex = 0;

    for (final match in matches) {
      final beforeBold = text.substring(lastIndex, match.start);
      final boldText = text.substring(match.start + 3, match.end - 4); // Remove <b> and </b>
      
      if (beforeBold.isNotEmpty) {
        textSpans.add(TextSpan(text: beforeBold));
      }
      textSpans.add(TextSpan(text: boldText, style: const TextStyle(fontWeight: FontWeight.bold)));
      
      lastIndex = match.end;
    }
    final remainingText = text.substring(lastIndex);
    if (remainingText.isNotEmpty) {
      textSpans.add(TextSpan(text: remainingText));
    }

    return textSpans;
  }
}
