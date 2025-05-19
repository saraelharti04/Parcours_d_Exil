import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:application_parcours_d_exil/hamburger_menu.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart'; // For PDF support
import 'package:video_player/video_player.dart'; // For video playback
import 'package:just_audio/just_audio.dart'; // For audio playback
import 'package:path_provider/path_provider.dart';
import 'dart:io'; // Import for File
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For encoding/decoding
import 'package:flutter_svg/flutter_svg.dart'; //  flutter_svg package
import 'dart:async';  // For timer
import 'favorites.dart';
import 'package:sembast/sembast_io.dart';
import 'package:flutter/material.dart';
import 'package:application_parcours_d_exil/login.dart';
import 'package:application_parcours_d_exil/therapist/messages_page.dart';
import 'package:application_parcours_d_exil/therapist/admin_page.dart';
import 'package:application_parcours_d_exil/therapist/account_page.dart';
import 'therapist/therapist_home_page.dart';
import 'package:application_parcours_d_exil/patient/patient_home_page.dart';
import 'package:application_parcours_d_exil/patient/patient_messages_page.dart';
import 'package:application_parcours_d_exil/patient/patient_account_page.dart';
import 'package:application_parcours_d_exil/patient/upcoming_events_page.dart';
import 'package:application_parcours_d_exil/therapist/ajouter_ressource_page.dart';
import 'package:application_parcours_d_exil/models/menu_item.dart';
import 'package:application_parcours_d_exil/models/ressource.dart';
import 'package:path/path.dart' as p;
import 'package:application_parcours_d_exil/database/ressource_dao.dart';
import 'package:audio_session/audio_session.dart';
import 'package:http/http.dart' as http;
import './appwrite_client.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;



final AppwriteClient appwriteClient = AppwriteClient();
// Global List for Favorites
List<Content> favoriteContents = [];

// Save favorites to local storage
Future<void> saveFavorites() async {
  final prefs = await SharedPreferences.getInstance();
  List<String> favoritesData = favoriteContents.map((content) {
    return jsonEncode({
      'title': content.title,
      'type': content.type,
      'filePath': content.filePath,
    });
  }).toList();
  await prefs.setStringList('favorites', favoritesData);
}

// Load favorites from local storage
Future<void> loadFavorites() async {
  final prefs = await SharedPreferences.getInstance();
  List<String>? favoritesData = prefs.getStringList('favorites');

  if (favoritesData != null) {
    favoriteContents = favoritesData.map((item) {
      final jsonContent = jsonDecode(item);
      return Content(
        title: jsonContent['title'],
        type: jsonContent['type'],
        filePath: jsonContent['filePath'],
      );
    }).toList();
  }
}

// Content structure used for the navigation and content display
class Content {
  final String title;
  final String type; // "video", "audio", "pdf", or "phone"
  final String filePath; // For PDFs or URLs
  final String? imagePath;
  final String? audioPathFR; //Audio path for French audio played in PDF viewer
  final String? audioPathEN;
  final String? phoneNumber; // For phone numbers
  final String? coverImagePath; // For cover images of audios
  final String? pdfLink; // link at the bottom of the PDF viewer
  final String?
  pdfLinkText; //link explanation text at the bottom of the PDF viewer
  final String? emailAddress; //  email address

  Content({
    required this.title,
    required this.type,
    required this.filePath,
    this.imagePath,
    this.audioPathFR,
    this.audioPathEN,
    this.phoneNumber,
    this.coverImagePath,
    this.pdfLink,
    this.pdfLinkText,
    this.emailAddress,
  });
}

// Menu-Item-Class
class MenuItem {
  final String title;
  final List<MenuItem>? subMenus; // Submenus (can be null)
  List<Content>? content; // Contents (Can be null)

  MenuItem({required this.title, this.subMenus, this.content});
}

// Menu Structure
final List<MenuItem> mainMenu = [
  //MODIFY for new main menu items

  // Parcours de Soins
  MenuItem(
    title: "Parcours de Soins",
    subMenus: [
      MenuItem(
        title: "Ateliers",
        content: [
          Content(
            title: "Atelier Français",
            type: "pdf",
            filePath:
            "assets/ressourcesPdE/Parcours de soin/Ateliers/Français/Atelier Français.pdf",
            audioPathEN:
                "assets/ressourcesPdE/Parcours de soin/Ateliers/Français/Audio Atelier Français-EN.m4a",
            audioPathFR:
                "assets/ressourcesPdE/Parcours de soin/Ateliers/Français/Audio Atelier Français-FR.m4a",
          ),
          Content(
            title: "Atelier Informatique",
            type: "pdf",
            filePath:
                "assets/ressourcesPdE/Parcours de soin/Ateliers/Informatique/Atelier Informatique.pdf",
            audioPathEN:
                "assets/ressourcesPdE/Parcours de soin/Ateliers/Informatique/Audio Atelier informatique-EN.m4a",
            audioPathFR:
                "assets/ressourcesPdE/Parcours de soin/Ateliers/Informatique/Audio Atelier informatique-FR.m4a",
          ),
          Content(
            title: "Atelier Musique",
            type: "pdf",
            filePath:
                "assets/ressourcesPdE/Parcours de soin/Ateliers/Musique/Atelier musique.pdf",
            audioPathEN:
                "assets/ressourcesPdE/Parcours de soin/Ateliers/Musique/Audio Atelier musique-EN.m4a",
            audioPathFR:
                "assets/ressourcesPdE/Parcours de soin/Ateliers/Musique/Audio Atelier musique-FR.m4a",
          ),
        ],
      ),
      MenuItem(
        title: "Groupe de Parole",
        content: [
          Content(
            title: "Présentation Groupe de Parole",
            type: "pdf",
            filePath:
                "assets/ressourcesPdE/Parcours de soin/Groupe de parole/Présentation groupe de parole.pdf",
            audioPathEN:
                "assets/ressourcesPdE/Parcours de soin/Groupe de parole/Groupe de parole-EN.m4a",
            audioPathFR:
                "assets/ressourcesPdE/Parcours de soin/Groupe de parole/Groupe de parole-FR.m4a",
            pdfLink: "https://parcours-exil.org/soigner/patients/",
            pdfLinkText: "Dates : ",
          ),
        ],
      ),
      MenuItem(
        title: "Professions de Santé",
        content: [
          Content(
            title: "Présentation Médecin",
            type: "pdf",
            filePath:
                "assets/ressourcesPdE/Parcours de soin/Professions de santé/Médecins/Présentation médecin.pdf",
            audioPathEN:
                "assets/ressourcesPdE/Parcours de soin/Professions de santé/Médecins/Consultation médecin-EN.m4a",
            audioPathFR:
                "assets/ressourcesPdE/Parcours de soin/Professions de santé/Médecins/Consultation médecin-FR.m4a",
          ),
          Content(
            title: "Présentation Ostéopathe",
            type: "pdf",
            filePath:
                "assets/ressourcesPdE/Parcours de soin/Professions de santé/Ostéopathes/Présentation ostéopathe.pdf",
            audioPathEN:
                "assets/ressourcesPdE/Parcours de soin/Professions de santé/Ostéopathes/Consultation ostéopathe-EN.m4a",
            audioPathFR:
                "assets/ressourcesPdE/Parcours de soin/Professions de santé/Ostéopathes/Consultation ostéopathe-FR.m4a",
          ),
          Content(
            title: "Présentation Psychologue",
            type: "pdf",
            filePath:
                "assets/ressourcesPdE/Parcours de soin/Professions de santé/Psychologues/Présentation psychologue.pdf",
            audioPathEN:
                "assets/ressourcesPdE/Parcours de soin/Professions de santé/Psychologues/Consultation psychologue-EN.m4a",
            audioPathFR:
                "assets/ressourcesPdE/Parcours de soin/Professions de santé/Psychologues/Consultation_psychologue_FR.m4a",
          ),
        ],
      ),
      MenuItem(
        title: "Suivi Thérapeutique",
        content: [
          Content(
            title: "Suivi Thérapeutique",
            type: "pdf",
            filePath:
                "assets/ressourcesPdE/Parcours de soin/Suivi thérapeutique/Suivi thérapeutique.pdf",
            audioPathEN:
                "assets/ressourcesPdE/Parcours de soin/Suivi thérapeutique/Suivi_therapeutique_EN.m4a",
            audioPathFR:
                "assets/ressourcesPdE/Parcours de soin/Suivi thérapeutique/Suivi thérapeutique-FR.m4a",
          ),
        ],
      ),
    ],
  ),

// Mes Besoins
  MenuItem(
    title: "Mes Besoins",
    subMenus: [
      MenuItem(
        title: "Me détendre",
        content: [
          Content(
            title: "Cohérence Cardiaque (CC) 5/5",
            type: "video",
            filePath:
                "assets/ressourcesPdE/SanteMentale/Respiration/exercice_55.mp4",
          ),
          Content(
            title: "Respiration abdominale",
            type: "video",
            filePath:
                "assets/ressourcesPdE/SanteMentale/DeQuoiAsTuBesoin/respiration_abdominale.mp4",
          ),
          Content(
            title: "Lieu ressource (Hypnose)",
            type: "audio",
            filePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/lieu_ressource.m4a",
                coverImagePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/santementale_autoapaisement_lieuressource.jpeg",
          ),
          Content(
            title: "Première expérience",
            type: "audio",
            filePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/premiere_experience.m4a",
                coverImagePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/santementale_autoapaisement_premiereexperience.jpeg",
          ),
          Content(
            title: "Sensation agréable",
            type: "audio",
            filePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/sensation_agreable.m4a",
                coverImagePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/santementale_autoapaisement_sensationagreable.jpeg",
          ),
          Content(
            title: "Concentration",
            type: "audio",
            filePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/concentration.m4a",
                coverImagePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/santementale_autoapaisement_concentration.jpeg",
          ),
          Content(
            title: "Retrouver de l'énergie",
            type: "audio",
            filePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/retrouver_de_l_energie.m4a",
                            coverImagePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/santementale_autoapaisement_energie.jpeg",
          ),
          Content(
            title: "Balayage corporel",
            type: "audio",
            filePath:
                "assets/ressourcesPdE/SanteMentale/Meditationenpleineconscience/balayage_corporel.m4a",
            coverImagePath:
                "assets/ressourcesPdE/SanteMentale/Meditationenpleineconscience/santementale_meditationpleineconscience_balayagecorporel.jpeg",
          ),
          Content(
            title: "Explorer un fruit, sens par sens",
            type: "audio",
            filePath:
                "assets/ressourcesPdE/SanteMentale/Meditationenpleineconscience/explorer_un_fruit_sens_par_sens.m4a",
            coverImagePath:
                "assets/ressourcesPdE/SanteMentale/Meditationenpleineconscience/santementale_meditationpleineconscience_explorerunfruit.jpeg",
          ),
        ],
      ),
      MenuItem(
        title: "Me calmer",
        content: [
          Content(
            title: "Cohérence Cardiaque (CC) 4/6",
            type: "video",
            filePath:
                "assets/ressourcesPdE/SanteMentale/Respiration/exercice_46.mp4",
          ),
          Content(
            title: "Respiration abdominale",
            type: "video",
            filePath:
                "assets/ressourcesPdE/SanteMentale/DeQuoiAsTuBesoin/respiration_abdominale.mp4",
          ),
          Content(
            title: "Tapotement papillon",
            type: "video",
            filePath:
                "assets/ressourcesPdE/SanteMentale/Stabilisation/ancrage_papillon.mp4",
          ),
          Content(
            title: "Contenant Simple",
            type: "audio",
            filePath:
                "assets/ressourcesPdE/SanteMentale/Stabilisation/contenant_1.mp3",
            coverImagePath:
                "assets/ressourcesPdE/SanteMentale/Stabilisation/santementale_stabilisation_contenantsimple.jpeg",
          ),
          Content(
            title: "Lieu ressource (Hypnose)",
            type: "audio",
            filePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/lieu_ressource.m4a",
                coverImagePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/santementale_autoapaisement_lieuressource.jpeg",
          ),
          Content(
            title: "HAVENING contre peur et anxiété",
            type: "video",
            filePath: "assets/ressourcesPdE/SanteMentale/EFT/havening.mp4",
          ),
          Content(
            title: "EFT simplifié",
            type: "video",
            filePath: "assets/ressourcesPdE/SanteMentale/EFT/eft.mp4",
          ),
          Content(
            title: "Equilibrage pour sortir de la confusion",
            type: "video",
            filePath: "assets/ressourcesPdE/SanteMentale/EFT/ttt.mp4",
          ),
          Content(
            title: "Souvenirs difficiles",
            type: "audio",
            filePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/souvenirs.mp3",
                coverImagePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/santementale_autoapaisement_souvenirsdifficiles.jpeg",
          ),
          Content(
            title: "Balayage corporel",
            type: "audio",
            filePath:
                "assets/ressourcesPdE/SanteMentale/Meditationenpleineconscience/balayage_corporel.m4a",
            coverImagePath:
                "assets/ressourcesPdE/SanteMentale/Meditationenpleineconscience/santementale_meditationpleineconscience_balayagecorporel.jpeg",
          ),
          Content(
            title: "Ancrage dans l'instant présent",
            type: "audio",
            filePath:
                "assets/ressourcesPdE/SanteMentale/Meditationenpleineconscience/ancrage_dans_l_instant_present.m4a",
            coverImagePath:
                "assets/ressourcesPdE/SanteMentale/Meditationenpleineconscience/santementale_meditationpleineconscience_ancragedanslinstantpresent.jpeg",
          ),
          Content(
            title: "Ancrage 54321",
            type: "audio",
            filePath:
                "assets/ressourcesPdE/SanteMentale/Stabilisation/ancrage_54321.m4a",
            coverImagePath:
                "assets/ressourcesPdE/SanteMentale/Stabilisation/ancrage_54321.jpeg",
          ),
        ],
      ),
      MenuItem(
        title: "M'endormir",
        content: [
          Content(
            title: "Cohérence Cardiaque (CC) 5/5",
            type: "video",
            filePath:
                "assets/ressourcesPdE/SanteMentale/Respiration/exercice_55.mp4",
          ),
          Content(
            title: "Respiration abdominale",
            type: "video",
            filePath:
                "assets/ressourcesPdE/SanteMentale/DeQuoiAsTuBesoin/respiration_abdominale.mp4",
          ),
          Content(
            title: "Lieu ressource (Hypnose)",
            type: "audio",
            filePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/lieu_ressource.m4a",
                coverImagePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/santementale_autoapaisement_lieuressource.jpeg",
          ),
          Content(
            title: "Apaiser ses pensées pour dormir",
            type: "audio",
            filePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/apaiser_ses_pensees_avant_le_sommeil.m4a",
                            coverImagePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/santementale_autoapaisement_apaiserlespenseesavantlesommeil.jpeg",
          ),
        ],
      ),
      MenuItem(
        title: "Bouger",
        content: [
          Content(
            title: "Les horaires des Parcs, jardins et bois",
            type: "map",
            filePath:
                "https://www.paris.fr/lieux/parcs-jardins-et-bois/tous-les-horaires",
          ),
          Content(
            title: "Où faire du sport en extérieur dans Paris ?",
            type: "map",
            filePath:
                "https://www.paris.fr/pages/ou-faire-du-sport-en-exterieur-dans-paris-18805",
          ),
        ],
      ),
    ],
  ),

  //Me sentir mieux (Santé Mentale)
  MenuItem(
    title: "Me sentir mieux",
    subMenus: [
      MenuItem(
        title: "Respiration",
        subMenus: [
          MenuItem(
            title: "Présentation",
            content: [
              Content(
                title: "Présentation de la cohérence cardiaque",
                type: "video",
                filePath:
                    "assets/ressourcesPdE/SanteMentale/Respiration/presentation_coherence_cardiaque.mp4",
              ),
              Content(
                title: "Respiration abdominale",
                type: "video",
                filePath:
                    "assets/ressourcesPdE/SanteMentale/DeQuoiAsTuBesoin/respiration_abdominale.mp4",
              ),
            ],
          ),
          MenuItem(
            title: "Exercices",
            content: [
              Content(
                title: "Cohérence cardiaque 5x5",
                type: "video",
                filePath:
                    "assets/ressourcesPdE/SanteMentale/Respiration/exercice_55.mp4",
              ),
              Content(
                title: "Cohérence cardiaque 4x6",
                type: "video",
                filePath:
                    "assets/ressourcesPdE/SanteMentale/Respiration/exercice_46.mp4",
              ),
              Content(
                title: "Respiration abdominale",
                type: "video",
                filePath:
                    "assets/ressourcesPdE/SanteMentale/DeQuoiAsTuBesoin/respiration_abdominale.mp4",
              ),
            ],
          ),
        ],
      ),
      MenuItem(
        title: "Stabilisation",
        content: [
          Content(
            title: "Ancrage 54321",
            type: "audio",
            filePath:
                "assets/ressourcesPdE/SanteMentale/Stabilisation/ancrage_54321.m4a",
            coverImagePath:
                "assets/ressourcesPdE/SanteMentale/Stabilisation/ancrage_54321.jpeg",
          ),
          Content(
            title: "Ancrage, tapotement papillon pied",
            type: "video",
            filePath:
                "assets/ressourcesPdE/SanteMentale/Stabilisation/ancrage_papillon.mp4",
          ),
          Content(
            title: "Contenant Simple",
            type: "audio",
            filePath:
                "assets/ressourcesPdE/SanteMentale/Stabilisation/contenant_1.mp3",
            coverImagePath:
                "assets/ressourcesPdE/SanteMentale/Stabilisation/santementale_stabilisation_contenantsimple.jpeg",
          ),
          Content(
            title: "Ancrage, papillon pied",
            type: "audio",
            filePath:
                "assets/ressourcesPdE/SanteMentale/Stabilisation/ancrage_papillon_pieds.m4a",
             coverImagePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/santementale_stabilisation_ancragepapillonpieds.jpeg",
          ),
        ],
      ),
      MenuItem(
        title: "EFT",
        content: [
          Content(
            title: "HAVENING contre peur et anxiété",
            type: "video",
            filePath: "assets/ressourcesPdE/SanteMentale/EFT/havening.mp4",
          ),
          Content(
            title: "EFT simplifié",
            type: "video",
            filePath: "assets/ressourcesPdE/SanteMentale/EFT/eft.mp4",
          ),
          Content(
            title: "Equilibrage pour sortir de la confusion",
            type: "video",
            filePath: "assets/ressourcesPdE/SanteMentale/EFT/ttt.mp4",
          ),
          Content(
            title: "Pdf ronde EFT",
            type: "pdf",
            filePath: "assets/ressourcesPdE/SanteMentale/EFT/ronde_EFT.pdf",
          ),
        ],
      ),
      MenuItem(
        title: "Auto-Apaisement",
        content: [
          Content(
            title: "Première expérience",
            type: "audio",
            filePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/premiere_experience.m4a",
            coverImagePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/santementale_autoapaisement_premiereexperience.jpeg",
          ),
          Content(
            title: "Sensation agréable",
            type: "audio",
            filePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/sensation_agreable.m4a",
            coverImagePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/santementale_autoapaisement_sensationagreable.jpeg",
          ),
          Content(
            title: "Concentration",
            type: "audio",
            filePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/concentration.m4a",
            coverImagePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/santementale_autoapaisement_concentration.jpeg",
          ),
          Content(
            title: "Apaiser ses pensées pour dormir",
            type: "audio",
            filePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/apaiser_ses_pensees_avant_le_sommeil.m4a",
            coverImagePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/santementale_autoapaisement_apaiserlespenseesavantlesommeil.jpeg",
          ),
          Content(
            title: "Retrouver de l'énergie",
            type: "audio",
            filePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/retrouver_de_l_energie.m4a",
            coverImagePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/santementale_autoapaisement_energie.jpeg",
          ),
          Content(
            title: "Lieu ressource",
            type: "audio",
            filePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/lieu_ressource.m4a",
            coverImagePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/santementale_autoapaisement_lieuressource.jpeg",
          ),
          Content(
            title: "Souvenirs difficiles",
            type: "audio",
            filePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/souvenirs.mp3",
            coverImagePath:
                "assets/ressourcesPdE/SanteMentale/AutoApaisement/santementale_autoapaisement_souvenirsdifficiles.jpeg",
          ),
        ],
      ),
      MenuItem(
        title: "Méditation pleine conscience",
        content: [
          Content(
            title: "Explorer un fruit, sens par sens",
            type: "audio",
            filePath:
                "assets/ressourcesPdE/SanteMentale/Meditationenpleineconscience/explorer_un_fruit_sens_par_sens.m4a",
            coverImagePath:
                "assets/ressourcesPdE/SanteMentale/Meditationenpleineconscience/santementale_meditationpleineconscience_explorerunfruit.jpeg",
          ),
          Content(
            title: "Balayage corporel",
            type: "audio",
            filePath:
                "assets/ressourcesPdE/SanteMentale/Meditationenpleineconscience/balayage_corporel.m4a",
            coverImagePath:
                "assets/ressourcesPdE/SanteMentale/Meditationenpleineconscience/santementale_meditationpleineconscience_balayagecorporel.jpeg",
          ),
          Content(
            title: "Ancrage dans l'instant présent",
            type: "audio",
            filePath:
                "assets/ressourcesPdE/SanteMentale/Meditationenpleineconscience/ancrage_dans_l_instant_present.m4a",
            coverImagePath:
                "assets/ressourcesPdE/SanteMentale/Meditationenpleineconscience/santementale_meditationpleineconscience_ancragedanslinstantpresent.jpeg",
          ),
        ],
      ),
      MenuItem(
        title: "Habitude de vie - Rythme de vie",
        content: [
          Content(
            title: "Présentation Hygiène de vie",
            type: "pdf",
            filePath:
                "assets/ressourcesPdE/SanteMentale/HabitudeDeVieRythmeDeVie/Hygienedevie.pdf",
            audioPathFR:
                "assets/ressourcesPdE/SanteMentale/HabitudeDeVieRythmeDeVie/Hygienedevie-FR.m4a",
            audioPathEN:
                "assets/ressourcesPdE/SanteMentale/HabitudeDeVieRythmeDeVie/Hygienedevie-EN.m4a",
          ),
        ],
      ),
    ],
  ),

// Calmer mes Douleurs (Corporel)
  MenuItem(
    title: "Calmer mes Douleurs",
    subMenus: [
      MenuItem(
        title: "Assouplissement",
        subMenus: [
          MenuItem(
            title: "Global",
            content: [
              Content(
                  title: "Chaine Antérieure",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Assouplissement/Global/chaine_anterieure.mp4"),
              Content(
                  title: "Chaine Latérale 1",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Assouplissement/Global/chaine_laterale_1.mp4"),
              Content(
                  title: "Chaine Latérale 2",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Assouplissement/Global/chaine_laterale_2.mp4"),
              Content(
                  title: "Chaine Postérieure",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Assouplissement/Global/chaine_posterieure.mp4"),
            ],
          ),
          MenuItem(
            title: "Membre Inférieur",
            content: [
              Content(
                  title: "Adducteurs",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Assouplissement/Membre_inferieur/adducteurs.mp4"),
              Content(
                  title: "Droit Antérieur",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Assouplissement/Membre_inferieur/droit_anterieur.mp4"),
              Content(
                  title: "Fessiers",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Assouplissement/Membre_inferieur/fessiers.mp4"),
              Content(
                  title: "Illio Psoas",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Assouplissement/Membre_inferieur/illio_psoas.mp4"),
              Content(
                  title: "Ischiojambier",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Assouplissement/Membre_inferieur/ischiojambier.mp4"),
              Content(
                  title: "Quadriceps",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Assouplissement/Membre_inferieur/quadriceps.mp4"),
              Content(
                  title: "Soléaire Triceps",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Assouplissement/Membre_inferieur/soleaire_triceps.mp4"),
            ],
          ),
          MenuItem(
            title: "Membre Supérieur",
            content: [
              Content(
                  title: "Epaules",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Assouplissement/Membre_superieur/epaules.mp4"),
              Content(
                  title: "Grand Dorsal",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Assouplissement/Membre_superieur/grand_dorsal.mp4"),
              Content(
                  title: "Trapèze 1",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Assouplissement/Membre_superieur/trapeze_1.mp4"),
              Content(
                  title: "Trapèze 2",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Assouplissement/Membre_superieur/trapeze_2.mp4"),
            ],
          ),
        ],
      ),
      MenuItem(
        title: "Mobilité",
        subMenus: [
          MenuItem(
            title: "Membre Inférieur",
            content: [
              Content(
                  title: "Cheville",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Mobilite/Membre_inferieur/cheville.mp4"),
              Content(
                  title: "Genou",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Mobilite/Membre_inferieur/genou.mp4"),
              Content(
                  title: "Hanche 1",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Mobilite/Membre_inferieur/hanche_1.mp4"),
              Content(
                  title: "Hanche 2",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Mobilite/Membre_inferieur/hanche_2.mp4"),
            ],
          ),
          MenuItem(
            title: "Membre Supérieur",
            content: [
              Content(
                  title: "Coude",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Mobilite/Membre_superieur/coude.mp4"),
              Content(
                  title: "Epaule",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Mobilite/Membre_superieur/epaule.mp4"),
              Content(
                  title: "Poignet",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Mobilite/Membre_superieur/poignet.mp4"),
            ],
          ),
          MenuItem(
            title: "Tronc",
            content: [
              Content(
                  title: "Cervicale",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Mobilite/Tronc/cervicale.mp4"),
              Content(
                  title: "Rachis",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Mobilite/Tronc/rachis.mp4"),
            ],
          ),
        ],
      ),
      MenuItem(
        title: "Renforcement",
        subMenus: [
          MenuItem(
            title: "Avec Elastique",
            content: [
              Content(
                  title: "Cheville 1",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Renforcement/AvecElastique/cheville_1.mp4"),
              Content(
                  title: "Cheville 2",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Renforcement/AvecElastique/cheville_2.mp4"),
              Content(
                  title: "Cheville 3",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Renforcement/AvecElastique/cheville_3.mp4"),
              Content(
                  title: "Cheville 4",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Renforcement/AvecElastique/cheville_4.mp4"),
              Content(
                  title: "Epaules RE",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Renforcement/AvecElastique/epaules_re.mp4"),
              Content(
                  title: "Epaules RI",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Renforcement/AvecElastique/epaules_ri.mp4"),
              Content(
                  title: "Genou",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Renforcement/AvecElastique/genou.mp4"),
              Content(
                  title: "Hanche ABD",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Renforcement/AvecElastique/hanche_abd.mp4"),
              Content(
                  title: "Hanche ADD",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Renforcement/AvecElastique/hanche_add.mp4"),
              Content(
                  title: "Scapula Bas",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Renforcement/AvecElastique/scapula_bas.mp4"),
              Content(
                  title: "Scapula Haut",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Renforcement/AvecElastique/scapula_haut.mp4"),
              Content(
                  title: "Scapula Haut 2",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Renforcement/AvecElastique/scapula_haut_2.mp4"),
              Content(
                  title: "Scapula Moyen",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Renforcement/AvecElastique/scapula_moyen.mp4"),
            ],
          ),
          MenuItem(
            title: "Gainage",
            content: [
              Content(
                  title: "Sur le Côté",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Renforcement/Gainage/sur_le_cote.mp4"),
              Content(
                  title: "Sur le Dos",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Renforcement/Gainage/sur_le_dos.mp4"),
              Content(
                  title: "Sur le Ventre 1",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Renforcement/Gainage/sur_le_ventre_1.mp4"),
              Content(
                  title: "Sur le Ventre 2",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Renforcement/Gainage/sur_le_ventre_2.mp4"),
            ],
          ),
          MenuItem(
            title: "Sur Marche",
            content: [
              Content(
                  title: "Triceps 1",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Renforcement/SurMarche/triceps_1.mp4"),
              Content(
                  title: "Triceps 2",
                  type: "video",
                  filePath:
                      "assets/ressourcesPdE/Corporel/Renforcement/SurMarche/triceps_2.mp4"),
            ],
          ),
        ],
      ),
    ],
  ),

// Mieux Comprendre (Psycho-Education)
// Mieux Comprendre (Psycho-Education)
MenuItem(
  title: "Mieux Comprendre",
  subMenus: [
    MenuItem(
      title: "Psychotraumatisme",
      subMenus: [
        MenuItem(
          title: "Informations Cn2r", // New submenu
          content: [
            Content(
              title: "Bloqué.e",
              type: "video",
              filePath:
                  "assets/ressourcesPdE/PsychoEducation/Psychotraumatisme/bloque.mp4",
            ),
            Content(
              title: "Les blessures invisibles",
              type: "video",
              filePath:
                  "assets/ressourcesPdE/PsychoEducation/Psychotraumatisme/les_blessures_invisibles_troubles_stress_post_traumatique.mp4",
            ),
            Content(
              title: "Se soigner - Comprendre",
              type: "video",
              filePath:
                  "assets/ressourcesPdE/PsychoEducation/Psychotraumatisme/se_soigner_comprendre.mp4",
            ),
            Content(
              title: "La sidération ou le syndrome de l'opossum",
              type: "video",
              filePath:
                  "assets/ressourcesPdE/PsychoEducation/Psychotraumatisme/la_sideration_ou_le_syndrome_de_lopossum.mp4",
            ),
          ],
        ),
      ],
      content: [
        Content(
          title: "Qu'est-ce que le psychotraumatisme ?",
          type: "video",
          filePath:
              "assets/ressourcesPdE/PsychoEducation/Psychotraumatisme/psychotraumatisme.mp4",
        ),
      ],
    ),
  ],
),

  //Aide au Quotidien
  MenuItem(
    title: "Aide au Quotidien",
    subMenus: [
      MenuItem(
        title: "Manger",
        subMenus: [
          MenuItem(
            title: "Matin",
            content: [
              Content(
                title: "P’TIT DÉJ’ SOLIDAIRES Jardin d’Éole",
                type: "map",
                filePath: "https://maps.app.goo.gl/UiDCKPHbbeaRiFw37",
              ),
              Content(
                title: "P'TIT DÉJ SMILE",
                type: "map",
                filePath: "https://maps.app.goo.gl/6AcVV2yoHeBdpxc9A",
              ),
              Content(
                title: "SOLIDARITÉ MIGRANTS WILSON",
                type: "map",
                filePath: "https://maps.app.goo.gl/JGj8bvyYSTQEstpv8",
              ),
            ],
          ),
          MenuItem(
            title: "Midi",
            content: [
              Content(
                title: "L’UN EST L’AUTRE / RESTO DU CŒUR",
                type: "map",
                filePath: "https://maps.app.goo.gl/3BoVZhNFjYzu9ohA6",
              ),
            ],
          ),
          MenuItem(
            title: "Soir",
            content: [
              Content(
                title: "L’UN EST L’AUTRE / LA CHORBA",
                type: "map",
                filePath: "https://maps.app.goo.gl/3t4dKe4qmLZSTght7",
              ),
              Content(
                title: "LA GAMELLE DE JAURÈS",
                type: "map",
                filePath: "https://maps.app.goo.gl/VK7omC3wQEHww2U89",
              ),
              Content(
                title: "SOLIDARITÉ MIGRANTS WILSON ",
                type: "map",
                filePath: "https://maps.app.goo.gl/VXKw1CJBVhq1PTQo8",
              ),
              Content(
                title: "LA FABRIQUE DU SOURIRE",
                type: "map",
                filePath: "https://maps.app.goo.gl/ez5qp5WANeGU5pif7",
              ),
              Content(
                title: "UNE CHORBA POUR TOUS",
                type: "map",
                filePath: "https://maps.app.goo.gl/y2zMhKBeU1qUDYFn7",
              ),
              Content(
                title: "RESTOS DU CŒUR",
                type: "map",
                filePath: "https://maps.app.goo.gl/DdYLrkHHZWEgmEsj6",
              ),
            ],
          ),
        ],
      ),
      MenuItem(
        title: "Se laver",
        subMenus: [
          MenuItem(
            title: "Laver ses vêtements",
            content: [
              Content(
                title: "LAVERIE SOLIDAIRE",
                type: "map",
                filePath: "https://maps.app.goo.gl/uNZmyKjKqvdTqgWq7",
              ),
            ],
          ),
          MenuItem(
            title: "Se laver",
            content: [
              Content(
                title: "BAINS-DOUCHES NEY",
                type: "map",
                filePath: "https://maps.app.goo.gl/RMTGGgQFp9KSxY1d6",
              ),
              Content(
                title: "BAINS-DOUCHES DES HAIES",
                type: "map",
                filePath: "https://maps.app.goo.gl/DzE4UidXodQg2dv96",
              ),
              Content(
                title: "BAINS-DOUCHES PYRÉNÉES",
                type: "map",
                filePath: "https://maps.app.goo.gl/h7mQPHsAHqjEK4yN7",
              ),
              Content(
                title: "BAINS-DOUCHES SAINT-MERRI",
                type: "map",
                filePath: "https://maps.app.goo.gl/hoSvUnj7kBCSdZ237",
              ),
              Content(
                title: "BAINS-DOUCHES MEAUX",
                type: "map",
                filePath: "https://maps.app.goo.gl/qz7pck8AigjgPPBq9",
              ),
              Content(
                title: "BAINS-DOUCHES OBERKAMPF",
                type: "map",
                filePath: "https://maps.app.goo.gl/1rNx33Jet2gD5J5D6",
              ),
              Content(
                title: "BAINS-DOUCHES LES AMIRAUX",
                type: "map",
                filePath: "https://maps.app.goo.gl/5pTU16Du8aaVYW986",
              ),
              Content(
                title: "LES AMARRES",
                type: "map",
                filePath: "https://maps.app.goo.gl/MoQFbn1mCtPPuq9U8",
              ),
            ],
          ),
        ],
      ),
      MenuItem(
        title: "Accueil de jour",
        subMenus: [
          MenuItem(
            title: "Personne sans hébergement",
            content: [
              Content(
                title: "HALTE HUMANITAIRE",
                type: "map",
                filePath: "https://maps.app.goo.gl/b8cVbGKrRFWov2MVA",
              ),
              Content(
                title: "LES AMARRES",
                type: "map",
                filePath: "https://maps.app.goo.gl/MoQFbn1mCtPPuq9U8",
              ),
            ],
          ),
          MenuItem(
            title: "Adulte sans enfant",
            content: [
              Content(
                title: "AUTREMONDE",
                type: "map",
                filePath: "https://maps.app.goo.gl/8qiwpRNV1QDEZzuD8",
              ),
              Content(
                title: "ESI AGORA",
                type: "map",
                filePath: "https://maps.app.goo.gl/1xJP7zJZQKsNeQjcA",
              ),
              Content(
                title: "MAISON DANS LA RUE",
                type: "map",
                filePath: "https://maps.app.goo.gl/uiJfhiomPDMMnJo56",
              ),
              Content(
                title: "LA MAISON DU PARTAGE",
                type: "map",
                filePath: "https://maps.app.goo.gl/aW94YGSgLAH1AtQVA",
              ),
              Content(
                title: "ESI RENÉ COTY",
                type: "map",
                filePath: "https://maps.app.goo.gl/o7hd1ZMJ59AdzEP39",
              ),
              Content(
                title: "ESI HALLE SAINT DIDIER",
                type: "map",
                filePath: "https://maps.app.goo.gl/ptKbjQzESwCRWEnm6",
              ),
              Content(
                title: "La MAISON DES REFUGIES",
                type: "map",
                filePath: "https://maps.app.goo.gl/PNhrQbPRmGXbMqZN8",
              ),
            ],
          ),
          MenuItem(
            title: "Adulte avec enfant",
            content: [
              Content(
                title: "AUTREMONDE",
                type: "map",
                filePath: "https://maps.app.goo.gl/8qiwpRNV1QDEZzuD8",
              ),
              Content(
                title: "ESI HALLE SAINT DIDIER",
                type: "map",
                filePath: "https://maps.app.goo.gl/eWRZLrsEJAk1FTyT7",
              ),
              Content(
                title: "MAISON DES REFUGIES",
                type: "map",
                filePath: "https://maps.app.goo.gl/PNhrQbPRmGXbMqZN8",
              ),
            ],
          ),
          MenuItem(
            title: "Homme",
            content: [
              Content(
                title: "ACCUEIL DE JOUR AUSTERLITZ",
                type: "map",
                filePath: "https://maps.app.goo.gl/76QkhnNmAjLhcPwSA",
              ),
              Content(
                title: "ACCUEIL DE JOUR CITÉ",
                type: "map",
                filePath: "https://maps.app.goo.gl/ZPbCPTFZNhuhJcj87",
              ),
              Content(
                title: "MAISON DES REFUGIES",
                type: "map",
                filePath: "https://maps.app.goo.gl/PNhrQbPRmGXbMqZN8",
              ),
            ],
          ),
          MenuItem(
            title: "Femme et famille",
            content: [
              Content(
                title: "ACCUEIL DE JOUR ABOUKIR",
                type: "map",
                filePath: "https://maps.app.goo.gl/TYRbmX2nxSmcHjyF8",
              ),
              Content(
                title: "ACCUEIL DE JOUR AUSTERLITZ",
                type: "map",
                filePath: "https://maps.app.goo.gl/76QkhnNmAjLhcPwSA",
              ),
              Content(
                title: "ESI GEORGETTE AGUTTE",
                type: "map",
                filePath: "https://maps.app.goo.gl/4usd5GyhaVFXjLKZ7",
              ),
              Content(
                title: "ESI BONNE NOUVELLE",
                type: "map",
                filePath: "https://maps.app.goo.gl/Eyx8TwBxSwePCrtd9",
              ),
              Content(
                title: "ESI FAMILLES PITARD EMMAÜS SOLIDARITÉ",
                type: "map",
                filePath: "https://maps.app.goo.gl/sGxBnfv1XXkVZ6jV7",
              ),
              Content(
                title: "REPAIRE SANTE BARBES",
                type: "map",
                filePath: "https://maps.app.goo.gl/dsWhsdk8LG5z3zWdA",
              ),
              Content(
                title: "AUTREMONDE",
                type: "map",
                filePath: "https://maps.app.goo.gl/pYzuM9cvkPhxRAPV8",
              ),
              Content(
                title: "MAISON DES REFUGIES",
                type: "map",
                filePath: "https://maps.app.goo.gl/PNhrQbPRmGXbMqZN8",
              ),
            ],
          ),
        ],
      ),
      MenuItem(
        title: "Se soigner",
        subMenus: [
          MenuItem(
            title: "Santé générale",
            content: [
              // HÔPITAL SAINT-LOUIS
              Content(
                title: "HÔPITAL SAINT-LOUIS",
                type: "pdf",
                filePath:
                    "assets/ressourcesPdE/Aide au quotidien/hospitals/saint_louis.pdf",
                pdfLink: "https://maps.app.goo.gl/8boy6kieB1v5ySzy7",
                pdfLinkText: "Navigation: ",
              ),

              // HÔTEL-DIEU
              Content(
                title: "HÔTEL-DIEU",
                type: "pdf",
                filePath:
                    "assets/ressourcesPdE/Aide au quotidien/hospitals/hotel_dieu.pdf",
                pdfLink: "https://maps.app.goo.gl/edpqfefy3hPXZHpT7",
                pdfLinkText: "Navigation: ",
              ),

              // HÔPITAL AVICENNE
              Content(
                title: "HÔPITAL AVICENNE",
                type: "pdf",
                filePath:
                    "assets/ressourcesPdE/Aide au quotidien/hospitals/avicenne.pdf",
                pdfLink: "https://maps.app.goo.gl/rLRyc5HMqsgMSijW7",
                pdfLinkText: "Navigation: ",
              ),

              // HÔPITAL LARIBOISIÈRE
              Content(
                title: "HÔPITAL LARIBOISIÈRE",
                type: "pdf",
                filePath:
                    "assets/ressourcesPdE/Aide au quotidien/hospitals/lariboisiere.pdf",
                pdfLink: "https://maps.app.goo.gl/mwihwBx59ncNbRBo8",
                pdfLinkText: "Navigation: ",
              ),

              // HÔPITAL PITIÉ SALPÊTRIÈRE
              Content(
                title: "HÔPITAL PITIÉ SALPÊTRIÈRE",
                type: "pdf",
                filePath:
                    "assets/ressourcesPdE/Aide au quotidien/hospitals/pitie_salpetriere.pdf",
                pdfLink: "https://maps.app.goo.gl/iGtTTbb7B6XQDqLo9",
                pdfLinkText: "Navigation: ",
              ),

              // HÔPITAL SAINT-ANTOINE
              Content(
                title: "HÔPITAL SAINT-ANTOINE",
                type: "pdf",
                filePath:
                    "assets/ressourcesPdE/Aide au quotidien/hospitals/saint_antoine.pdf",
                pdfLink: "https://maps.app.goo.gl/6iu1TXPpfrJi91XP7",
                pdfLinkText: "Navigation: ",
              ),

              // HÔPITAL AMBROISE PARÉ
              Content(
                title: "HÔPITAL AMBROISE PARÉ",
                type: "pdf",
                filePath:
                    "assets/ressourcesPdE/Aide au quotidien/hospitals/ambroise_pare.pdf",
                pdfLink: "https://maps.app.goo.gl/vkpoJJPgkwBAHFTL9",
                pdfLinkText: "Navigation: ",
              ),

              // HÔPITAL ANTOINE BÉCLÈRE
              Content(
                title: "HÔPITAL ANTOINE BÉCLÈRE",
                type: "pdf",
                filePath:
                    "assets/ressourcesPdE/Aide au quotidien/hospitals/antoine_beclere.pdf",
                pdfLink: "https://maps.app.goo.gl/F2K1ZNyGeRRijiZAA",
                pdfLinkText: "Navigation: ",
              ),

              // HÔPITAL BEAUJON
              Content(
                title: "HÔPITAL BEAUJON",
                type: "pdf",
                filePath:
                    "assets/ressourcesPdE/Aide au quotidien/hospitals/beaujon.pdf",
                pdfLink: "https://maps.app.goo.gl/MuNjZHekJPqFFoFa9",
                pdfLinkText: "Navigation: ",
              ),

              // HÔPITAL KREMLIN BICÊTRE
              Content(
                title: "HÔPITAL KREMLIN BICÊTRE",
                type: "pdf",
                filePath:
                    "assets/ressourcesPdE/Aide au quotidien/hospitals/kremlin_bicetre.pdf",
                pdfLink: "https://maps.app.goo.gl/xLFEzER5zAqPXUjC9",
                pdfLinkText: "Navigation: ",
              ),

              // HÔPITAL BICHAT
              Content(
                title: "HÔPITAL BICHAT",
                type: "pdf",
                filePath:
                    "assets/ressourcesPdE/Aide au quotidien/hospitals/bichat.pdf",
                pdfLink: "https://maps.app.goo.gl/gctKUc3TV9HDxZXA9",
                pdfLinkText: "Navigation: ",
              ),

              // HÔPITAL COCHIN
              Content(
                title: "HÔPITAL COCHIN",
                type: "map",
                filePath: "https://maps.app.goo.gl/DrsWd6WtKF176RSE9",
              ),

              // HÔPITAL CORENTIN CELTON
              Content(
                title: "HÔPITAL CORENTIN CELTON",
                type: "pdf",
                filePath:
                    "assets/ressourcesPdE/Aide au quotidien/hospitals/corentin_celton.pdf",
                pdfLink: "https://maps.app.goo.gl/nNxGp5eB8GuZP22E7",
                pdfLinkText: "Navigation: ",
              ),

              // HÔPITAL HENRI-MONDOR
              Content(
                title: "HÔPITAL HENRI-MONDOR",
                type: "pdf",
                filePath:
                    "assets/ressourcesPdE/Aide au quotidien/hospitals/henri_mondor.pdf",
                pdfLink: "https://maps.app.goo.gl/wqUdxsn2RkPqHc3y7",
                pdfLinkText: "Navigation: ",
              ),

              // HÔPITAL EUROPÉEN GEORGES POMPIDOU
              Content(
                title: "HÔPITAL EUROPÉEN GEORGES POMPIDOU",
                type: "pdf",
                filePath:
                    "assets/ressourcesPdE/Aide au quotidien/hospitals/europeen_georges_pompidou.pdf",
                pdfLink: "https://maps.app.goo.gl/1TidBGWbC7voVbzY7",
                pdfLinkText: "Navigation: ",
              ),

              // HÔPITAL JEAN VERDIER
              Content(
                title: "HÔPITAL JEAN VERDIER",
                type: "map",
                filePath: "https://maps.app.goo.gl/bN2TwEcfF1R1HaF8A",
              ),

              // HÔPITAL PAUL BROUSSE
              Content(
                title: "HÔPITAL PAUL BROUSSE",
                type: "map",
                filePath: "https://maps.app.goo.gl/SQEdW2gEig8zfA7b6",
              ),
            ],
          ),
          MenuItem(
            title: "Dentaire",
            content: [
              Content(
                title: "LE BUS SOCIAL DENTAIRE",
                type: "map",
                filePath: "https://maps.app.goo.gl/cpQUjjQNRtR5JVt37",
              ),

              Content(
                title: "LE BUS SOCIAL DENTAIRE (Alternate link)",
                type: "map",
                filePath: "https://maps.app.goo.gl/rcaq3PEvNUhwhChP8",
              ),

              // HÔTEL-DIEU
              Content(
                title: "HÔTEL-DIEU PASS DENTAIRE",
                type: "pdf",
                filePath:
                    "assets/ressourcesPdE/Aide au quotidien/hospitals/hotel_dieu.pdf",
                pdfLink: "https://maps.app.goo.gl/edpqfefy3hPXZHpT7",
                pdfLinkText: "Navigation: ",
              ),
              Content(
                title: "HÔPITAL LOUIS MOURIER",
                type: "pdf",
                filePath:
                    "assets/ressourcesPdE/Aide au quotidien/hospitals/louis_mourier.pdf",
                pdfLink: "https://maps.app.goo.gl/3p7rFiMFjk56FDFH6",
                pdfLinkText: "Navigation: ",
              ),
            ],
          ),
          MenuItem(
            title: "Audition",
            content: [
              Content(
                title: "AUDITION SOLIDARITÉ",
                type: "map",
                filePath:
                    "https://www.auditionsolidarite.org/fr/rdv-solidaires/",
              ),
              Content(
                title: " Les RDV Solidaires d'Audition Solidarité (Video)",
                type: "map",
                filePath: "https://youtu.be/C16nokdGrd0?si=Bj5MNQtbqdNm0H9O",
              ),
            ],
          ),
          MenuItem(
            title: "Ophtalmologie",
            content: [
              Content(
                title: "PASS O",
                type: "map",
                filePath: "https://maps.app.goo.gl/eWLwJ49v5j3Cqbtt5",
              ),
              // HÔTEL-DIEU
              Content(
                title: "HÔTEL-DIEU PASS Ophtalmo",
                type: "pdf",
                filePath:
                    "assets/ressourcesPdE/Aide au quotidien/hospitals/hotel_dieu.pdf",
                pdfLink: "https://maps.app.goo.gl/edpqfefy3hPXZHpT7",
                pdfLinkText: "Navigation: ",
              ),
            ],
          ),
          MenuItem(
            title: "Dermatologie",
            content: [
              Content(
                title: "HÔPITAL LOUIS MOURIER PASS Dermato",
                type: "pdf",
                filePath:
                    "assets/ressourcesPdE/Aide au quotidien/hospitals/louis_mourier.pdf",
                pdfLink: "https://maps.app.goo.gl/3p7rFiMFjk56FDFH6",
                pdfLinkText: "Navigation: ",
              ),
            ],
          ),
          MenuItem(
            title: "Femmes et enfants",
            content: [
              Content(
                title: "HÔTEL-DIEU Centre de protection maternelle",
                type: "map",
                filePath: "https://maps.app.goo.gl/89MgbeCam7jaLnN39",
              ),
              Content(
                title: "HÔPITAL ROBERT-DEBRÉ PASS",
                type: "map",
                filePath: "https://maps.app.goo.gl/Xok7QWB4dozWcpjv6",
              ),
              Content(
                title: "HÔPITAL NECKER ENFANTS MALADES PASS",
                type: "map",
                filePath: "https://maps.app.goo.gl/iL5MibdQ9BArarzv8",
              ),
              Content(
                title: "REPAIRE SANTÉ BARBES",
                type: "map",
                filePath: "https://maps.app.goo.gl/Cjhg4wsgdXKpo1Zt7",
              ),
              Content(
                title: "SOLIPAM",
                type: "phone",
                filePath: "",
                phoneNumber: "0148241628",
              ),
              Content(
                title: "PMI CURIAL",
                type: "map",
                filePath: "https://maps.app.goo.gl/TmjZ9EkGQrC639JHA",
              ),
              Content(
                title: "PMI FLANDRE",
                type: "map",
                filePath: "https://maps.app.goo.gl/Q8WxjMdyaGd2HkJS7",
              ),
              Content(
                title: "HÔPITAL Ambroise Paré",
                type: "map",
                filePath: "https://maps.app.goo.gl/vkpoJJPgkwBAHFTL9",
              ),
            ],
          ),
          MenuItem(
            title: "Urgence Santé Mentale",
            content: [
              Content(
                title: "C.P.O.A HÔPITAL SAINT-ANNE",
                type: "map",
                filePath: "https://maps.app.goo.gl/bw9yFJNaLa51esnr8",
              ),
            ],
          ),
        ],
      ),
      MenuItem(
        title: "S'habiller",
        content: [
          Content(
            title: "VESTIAIRE ÉGLISE SAINT-BERNARD",
            type: "map",
            filePath: "https://maps.app.goo.gl/bK3Ph6JNCSKLL1No9",
          ),
          Content(
            title: "VESTIAIRE ÉGLISE SAINT-AUGUSTIN",
            type: "map",
            filePath: "https://maps.app.goo.gl/BKghPxTE5xL5iPiS9",
          ),
        ],
      ),
      MenuItem(
        title: "Faire du sport",
        content: [
          Content(
            title: "Où faire du sport en extérieur dans Paris ?",
            type: "map",
            filePath:
                "https://www.paris.fr/pages/ou-faire-du-sport-en-exterieur-dans-paris-18805",
          ),
          Content(
            title: "JRS (Facebook)",
            type: "map",
            filePath:
                "https://www.facebook.com/search/top?q=jrs%20jeunes%20paris",
          ),
          Content(
            title: "JRS (Phone)",
            type: "phone",
            filePath: "",
            phoneNumber: "0667965244",
          ),
          Content(
            title: "JRS (Maps)",
            type: "map",
            filePath: "https://maps.app.goo.gl/Wu3F23JyrsCrceWj7",
          ),
          Content(
              title: "VIKING SFA FC Football ",
              type: "email",
              filePath: "",
              emailAddress: "contact@vikingclub.paris"),
          Content(
            title: "NOUR Yoga",
            type: "map",
            filePath: "https://reservation.nour-yoga.com",
          ),
          Content(
            title: "KABUBU",
            type: "map",
            filePath: "https://www.kabubu.fr/fr/paris",
          ),
          Content(
            title: "CEDRE (Website)",
            type: "map",
            filePath:
                "https://www.secours-catholique.org/le-cedre-un-centre-dentraide-dedie-aux-demandeurs-dasile-et-aux-refugies",
          ),
          Content(
            title: "CEDRE (Maps)",
            type: "map",
            filePath: "https://maps.app.goo.gl/KYb3RQQiuYso6cGZ8",
          ),
          Content(
            title: "CEDRE (Phone)",
            type: "phone",
            filePath: "",
            phoneNumber: "0148391092",
          ),
        ],
      ),
      MenuItem(
        title: "Activités et Sorties",
        content: [

          Content(
            title: "Les horaires des Parcs, jardins et bois",
            type: "map",
            filePath:
                "https://www.paris.fr/lieux/parcs-jardins-et-bois/tous-les-horaires",
          ),
          Content(
            title: "La Maison Bakhita",
            type: "map",
            filePath: "https://www.maisonbakhita.fr/page/2729546-accueil",
          ),
          Content(
            title: "La Maison Bakhita (Maps)",
            type: "map",
            filePath: "https://maps.app.goo.gl/1qTGVUXG2XHhdmzk8",
          ),
          Content(
            title: "La Maison Bakhita (Phone)",
            type: "phone",
            filePath: "",
            phoneNumber: "0188614865",
          ),
          Content(
            title: "CEDRE",
            type: "map",
            filePath:
                "https://www.secours-catholique.org/le-cedre-un-centre-dentraide-dedie-aux-demandeurs-dasile-et-aux-refugies",
          ),
          Content(
            title: "CEDRE (Maps)",
            type: "map",
            filePath: "https://maps.app.goo.gl/KYb3RQQiuYso6cGZ8",
          ),
          Content(
            title: "CEDRE (Phone)",
            type: "phone",
            filePath: "",
            phoneNumber: "0148391092",
          ),
          Content(
            title: "LIMBO",
            type: "map",
            filePath: "https://limbo-asso.com/lespace-dart-therapie/",
          ),
          Content(
            title: "LIMBO (Maps)",
            type: "map",
            filePath: "https://maps.app.goo.gl/A2KS9MgcZSZPXP1S8",
          ),
          Content(
            title: "LIMBO (Email)",
            type: "map",
            filePath: "ateliers.limbo@gmail.com",
          ),
          Content(
            title: "POLARIS 14",
            type: "map",
            filePath: "https://polaris14.org/",
          ),
          Content(
            title: "POLARIS 14 (Maps)",
            type: "map",
            filePath: "https://maps.app.goo.gl/pvupjgguUTFUxx5c6",
          ),
          Content(
            title: "MAISON DES REFUGIES",
            type: "map",
            filePath: "https://maps.app.goo.gl/35WPNNeDnijQkYJq6",
          ),
          Content(
            title: "JRS",
            type: "map",
            filePath: "https://fr-fr.facebook.com/jrsjeunesparis/",
          ),
          Content(
            title: "JRS (Phone)",
            type: "phone",
            filePath: "",
            phoneNumber: "0667965244",
          ),
          Content(
            title: "JRS (Maps)",
            type: "map",
            filePath: "https://maps.app.goo.gl/Wu3F23JyrsCrceWj7",
          ),
        ],
      ),
    ],
  ),

// Urgences 
  MenuItem(
    title: "Urgences",
    subMenus: [
      MenuItem(
        title: "Urgences",
        content: [
          Content(
            title: "SAMU - urgence médicale",
            type: "phone",
            phoneNumber: "15",
            filePath: "",
          ),
          Content(
            title: "Pompiers - situation de péril ou d'accident",
            type: "phone",
            phoneNumber: "18",
            filePath: "",
          ),
          Content(
            title: "Police secours- signaler une infraction",
            type: "phone",
            phoneNumber: "17",
            filePath: "",
          ),
          Content(
            title: "Alerte attentat",
            type: "phone",
            phoneNumber: "197",
            filePath: "",
          ),
          Content(
            title: "Canicule info service",
            type: "phone",
            phoneNumber: "0 800 06 66 66",
            filePath: "",
          ),
          Content(
            title: "Tchat avec la Police",
            type: "map",
            filePath:
                "https://www.masecurite.interieur.gouv.fr/fr/echange-tchat-police",
          ),
          Content(
            title: "Urgence en Europe - urgence médicale, infraction- péril",
            type: "phone",
            phoneNumber: "112",
            filePath: "",
          ),
        ],
      ),
      MenuItem(
        title: "Idées Suicidaires",
        content: [
          Content(
            title: "Prévention du suicide",
            type: "phone",
            phoneNumber: "31 14",
            filePath: "",
          ),
          Content(
            title: "Centre antipoison - surdosage médicaments",
            type: "map",
            filePath: "https://centres-antipoison.net/",
          ),
          Content(
            title: "Centre antipoison - surdosage médicaments Paris",
            type: "phone",
            phoneNumber: "01 40 05 48 48",
            filePath: "",
          ),
          Content(
            title: "Ecoute - SOS Amitié (7j/7 et 24h/24)",
            type: "phone",
            phoneNumber: "09 72 39 40 50",
            filePath: "",
          ),
          Content(
            title: "Ecoute - SOS Amitié (par Tchat) (7j/7 13h-03h00)",
            type: "map",
            filePath: "https://www.sos-amitie.com/chat/",
          ),
          Content(
            title: "SOS Help (in English) (7/7 3PM-11PM)",
            type: "phone",
            phoneNumber: "01 46 21 46 46",
            filePath: "",
          ),
          Content(
            title: "Suicide écoute (7j/7 et 24h/24)",
            type: "phone",
            phoneNumber: "01 45 39 40 00",
            filePath: "",
          ),
        ],
      ),
      MenuItem(
        title: "Lignes d'écoute",
        content: [
          Content(
            title:
                "Soutien psychologique Croix-Rouge (du lundi au vendredi 9h-19h, samedi dimanche de 12h-18h)",
            type: "phone",
            phoneNumber: "0 800 858 858",
            filePath: "",
          ),
          Content(
            title: "Ecoute - SOS Amitié (7j/7 et 24h/24)",
            type: "phone",
            phoneNumber: "09 72 39 40 50",
            filePath: "",
          ),
          Content(
            title: "Ecoute - SOS Amitié (par Tchat) (7j/7 13h-03h00)",
            type: "map",
            filePath: "https://www.sos-amitie.com/chat/",
          ),
          Content(
            title: "SOS Help (in English) (7/7 3PM-11PM)",
            type: "phone",
            phoneNumber: "01 46 21 46 46",
            filePath: "",
          ),
          Content(
            title: "Ecoute - SOS crise (lundi au samedi 9h-19h)",
            type: "phone",
            phoneNumber: "0800 19 00 00",
            filePath: "",
          ),
        ],
      ),
      MenuItem(
        title: "Violences",
        content: [
          Content(
            title: "Enfance en danger - violences sur mineurs",
            type: "phone",
            phoneNumber: "119",
            filePath: "",
          ),
          Content(
            title: "Enfance en danger (numéro d'urgence européen)",
            type: "phone",
            phoneNumber: "116 111",
            filePath: "",
          ),
          Content(
            title: "Femmes victimes de violence",
            type: "phone",
            phoneNumber: "39 19",
            filePath: "",
          ),
          Content(
            title: "SOS homophobie",
            type: "phone",
            phoneNumber: "01 48 06 42 41",
            filePath: "",
          ),
        ],
      ),
    ],
  ),

  //Favoris 
  MenuItem(
    title: "Favoris",
    subMenus: [], // No submenus for favorites, later in the code there is functionality so it just navigates directly to the favorites page
    content: [], // No content directly here
  ),
];


class Home extends StatefulWidget {
  final bool isTherapist;
  final bool isPatient;

  const Home({super.key, required this.isTherapist, required this.isPatient});

  @override
  HomeState createState() => HomeState();
}


class HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  Future<List<Widget>> _buildTherapistPages() async {
    final prefs = await SharedPreferences.getInstance();
    final therapistId = prefs.getString('user_id') ?? '';

    return [
      MessagesPage(therapistId: therapistId),
      const TherapistHomePage(),
      const AdminPage(),
      const AccountPage(),
    ];
  }

  Future<List<Widget>> _buildPatientPages() async {
    final prefs = await SharedPreferences.getInstance();
    final patientId = prefs.getString('user_id') ?? '';

    return [
      PatientMessagesPage(patientId: patientId),
      const PatientHomePage(),
      const PatientAccountPage(),
      const UpcomingEventsPage(),
    ];
  }


  @override
  Widget build(BuildContext context) {
    bool showBottomNavBar = widget.isTherapist || widget.isPatient;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(automaticallyImplyLeading: false,
        title: Text(
          widget.isTherapist
              ? 'Mode Thérapeute'
              : widget.isPatient
              ? 'Mode Patient'
              : 'Parcours d\'Exil',
          style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 28.0, color: Colors.black),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          if (widget.isTherapist && _selectedIndex == 1)
            IconButton(
              icon: const Icon(Icons.add, size: 28.0, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AjouterRessourcePage()),
                );
              },
            ),

          if (!widget.isTherapist && !widget.isPatient)
            IconButton(
              icon: const Icon(Icons.login, size: 28.0, color: Colors.black),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
        ],

        backgroundColor: Colors.white,
        elevation: 5.0,
      ),
      drawer: HamburgerMenu(),
      body: FutureBuilder<List<Widget>>(
        future: widget.isTherapist
            ? _buildTherapistPages()
            : _buildPatientPages(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final pages = snapshot.data!;
          return pages[_selectedIndex];
        },
      ),
      bottomNavigationBar: showBottomNavBar
          ? BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: widget.isTherapist
            ? const [
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Messages"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings), label: "Admin"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Mon compte"),
        ]
            : const [
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Messages"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Mon compte"),
          BottomNavigationBarItem(
              icon: Icon(Icons.event), label: "Prochainement"),
        ],
      )
          : null,
    );
  }


  @override
  void initState() {
    super.initState();
    loadMergedMenu();
  }

  Future<List<models.File>> fetchAppwriteFiles() async {
    try {
      final result = await appwriteClient.storage.listFiles(
        bucketId: '6825cfaf00103670137a',
      );
      return result.files;
    } on AppwriteException catch (e) {
      debugPrint('Erreur Appwrite: ${e.message}');
      return [];
    }
  }

  Future<List<MenuItem>> loadMergedMenu() async {
    final List<MenuItem> mergedMenu = List<MenuItem>.from(mainMenu);
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'parcours_exil.db');
    final database = await databaseFactoryIo.openDatabase(dbPath);
    final dao = RessourceDao(database);

    const appwriteProjectId = '6825cc670032c4d0b58e';
    const appwriteBucketId = '6825cfaf00103670137a';

    try {
      // 1. Récupérer toutes les ressources déjà présentes en local (ex: par leur ID)
      final existingResources = await dao.getAll();
      final existingIds = existingResources.map((r) => r.id).toSet();

      // 2. Requête distante
      final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/ressources/all'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        for (var json in data) {
          final id = json['_id'] ?? '';
          final titre = json['titre'] ?? '';
          final cat = json['categorie'] ?? 'Autre';
          final sub = json['sousCategorie'] ?? 'Général';
          final fileId = json['fichier'] ?? '';

          if (id.isEmpty || titre.isEmpty || fileId.isEmpty) continue;

          // 3. Si la ressource existe déjà, on ne la télécharge pas
          if (existingIds.contains(id)) {
            continue;
          }

          final fileUrl =
              'https://fra.cloud.appwrite.io/v1/storage/buckets/$appwriteBucketId/files/$fileId/download?project=$appwriteProjectId&mode=admin';

          final fileResponse = await http.get(Uri.parse(fileUrl));

          if (fileResponse.statusCode == 200) {
            final fileBytes = fileResponse.bodyBytes;
            final fileType = json['type'] ?? 'application/octet-stream';

            final mimeExtensions = {
              "mp3": "mp3",
              "mp4": 'mp4',
              "pdf": 'pdf',
              "png": "png",
              "jpg": "jpg",
              'audio/mpeg': 'mp3',
              'audio/mp3': 'mp3',
              'audio/wav': 'wav',
              'audio/x-wav': 'wav',
              'audio/aac': 'aac',
              'audio/x-m4a': 'm4a',
              'audio/ogg': 'ogg',
              'audio/webm': 'webm',
              'video/mp4': 'mp4',
              'video/webm': 'webm',
              'application/pdf': 'pdf',
              'application/octet-stream': 'bin',
            };

            final extension = mimeExtensions[fileType] ?? 'bin';
            final safeTitre = titre.replaceAll(RegExp(r'[^\w\s-]'), '_');
            final filename = '$safeTitre.$extension';
            final filePath = p.join(dir.path, filename);
            final file = File(filePath);
            await file.writeAsBytes(fileBytes);

            final newRessource = Ressource(
              id: id,
              titre: titre,
              type: fileType,
              fichier: filePath,
              categorie: cat,
              sousCategorie: sub,
              audioFR: json['audioFR'] ?? '',
              audioEN: json['audioEN'] ?? '',
              image: json['image'] ?? '',
            );
            await dao.insert(newRessource);
            existingIds.add(id); // Ajoute à la liste des IDs existants
          } else {
            print('❌ Échec téléchargement fichier Appwrite : ${fileResponse.statusCode}');
          }
        }
      } else {
        print('❌ Erreur serveur backend : ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception lors de la synchro distante : $e');
    }

    // Après synchro, on récupère tout depuis la base locale (mise à jour)
    final ressources = await dao.getAll();

    for (var res in ressources) {
      final cat = res.categorie;
      final sub = res.sousCategorie;

      final category = mergedMenu.firstWhere(
            (m) => m.title == cat,
        orElse: () {
          final newCat = MenuItem(title: cat, subMenus: []);
          mergedMenu.add(newCat);
          return newCat;
        },
      );

      final subCategory = category.subMenus!.firstWhere(
            (s) => s.title == sub,
        orElse: () {
          final newSub = MenuItem(title: sub, content: []);
          category.subMenus!.add(newSub);
          return newSub;
        },
      );

      subCategory.content ??= [];

      final alreadyExists = subCategory.content!.any((c) =>
      c.title == res.titre && c.filePath == res.fichier);

      if (!alreadyExists) {
        subCategory.content!.add(
          Content(
            title: res.titre,
            type: res.type,
            filePath: res.fichier,
            imagePath: res.image,
            audioPathFR: res.audioFR,
            audioPathEN: res.audioEN,
          ),
        );
      }
    }

    return mergedMenu;
  }








  Widget _buildMainMenu() {
    return FutureBuilder<List<MenuItem>>(
      future: loadMergedMenu(), // 👈 charge les ressources depuis la base
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Erreur: ${snapshot.error}"));
        }

        // Fusionne le menu statique et le menu dynamique
        final allMenuItems = snapshot.data ?? [];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 1.0,
              ),
              itemCount: allMenuItems.length,
              itemBuilder: (context, index) {
                final menuItem = allMenuItems[index];
                return _buildAnimatedTile(context, menuItem);
              },
            ),
          ),
        );
      },
    );
  }
}
  class TherapistHomePage extends StatelessWidget {
  const TherapistHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeState()._buildMainMenu();
  }
}

class PatientHomePage extends StatelessWidget {
  const PatientHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeState()._buildMainMenu();
  }
}

Widget _buildAnimatedTile(BuildContext context, MenuItem menuItem) {
  return GestureDetector(
    onTap: () {
      if (menuItem.title == "Favoris") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FavoritesPage()),
        );
      } else {
        if ((menuItem.subMenus?.isNotEmpty ?? false) || (menuItem.content?.isNotEmpty ?? false)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MenuPage(
                title: menuItem.title,
                menuItems: menuItem.subMenus ?? [],
                content: menuItem.content ?? [],
              ),
            ),
          );
        }
      }
    },
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_getImageForMenuItem(menuItem.title)),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20.0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menuItem.title,
                    style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  if (menuItem.title == "Me sentir mieux")
                    const Text('Santé Mentale', style: TextStyle(fontSize: 14.0, color: Colors.white70)),
                  if (menuItem.title == "Mieux Comprendre")
                    const Text('Psycho-Éducation', style: TextStyle(fontSize: 14.0, color: Colors.white70)),
                  if (menuItem.title == "Calmer mes Douleurs")
                    const Text('Corporel', style: TextStyle(fontSize: 14.0, color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


  //MODIFY for new main menu items, this loads the image for the menu item
  String _getImageForMenuItem(String title) {
    switch (title) {
      case "Parcours de Soins":
        return "assets/icons/parcoursSoins.png";
      case "Me sentir mieux":
        return "assets/icons/santementale.png";
      case "Aide au Quotidien":
        return "assets/icons/aideAuQuotidien.png";
      case "Mieux Comprendre":
        return "assets/icons/psychoEducation.png";
      case "Calmer mes Douleurs":
        return "assets/icons/corporel.png";
      case "Mes Besoins":
        return "assets/icons/mesBesoins.png";
      case "Urgences":
        return "assets/icons/urgences.png";
      case "Favoris":
        return "assets/icons/favorite.png";
      default:
        return "assets/icons/audio_placeholder.png";
    }
  }


// This generates the menu pages with submenus and content
class MenuPage extends StatelessWidget {
  final String title;
  final List<MenuItem> menuItems;
  final List<Content> content;

  const MenuPage({
    required this.title,
    this.menuItems = const [],
    this.content = const [],
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const colors = [
      Color(0xFFFFEEB0), // #ffeeb0
      Color(0xFFFFE5E5), // #ffe5e5
      Color(0xFFECDAFF), // #ecdaff
      Color(0xFFDAFAF7), // #dafaf7
      Color(0xFFB4F5AD), // #b4f5ad
      Color(0xFFFFB8E6), // #ffb8e6
      Color(0xFFDFF8FF), // #dff8ff
      Color(0xFFFFFDE6), // #fffde6
    ];

return Scaffold(
  appBar: PreferredSize(
    preferredSize: const Size.fromHeight(kToolbarHeight + 20), // Height of the AppBar + padding
    child: Padding(
      padding: const EdgeInsets.only(top: 20.0), // Padding above the AppBar content
      child: AppBar(automaticallyImplyLeading: false,
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/home'));
            },
          ),
        ],
      ),
    ),
  ),
  body: SafeArea(
    child: ListView(
      padding: const EdgeInsets.all(10.0),
      children: [
        ...menuItems.asMap().entries.map(
          (entry) {
            final index = entry.key;
            final menuItem = entry.value;
            final color = colors[index % colors.length];
            return _buildAnimatedSubMenuItem(context, menuItem, color);
          },
        ),
        ...content.asMap().entries.map(
          (entry) {
            final index = entry.key;
            final item = entry.value;
            final color =
                colors[(menuItems.length + index) % colors.length];
            return _buildAnimatedContentItem(context, item, color);
          },
        ),
      ],
    ),
  ),
);

  }

  Widget _buildAnimatedSubMenuItem(
      BuildContext context, MenuItem menuItem, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuPage(
              title: menuItem.title,
              menuItems: menuItem.subMenus ?? [],
              content: menuItem.content ?? [],
            ),
          ),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
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
            title: Text(
              menuItem.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward),
          ),
        ),
      ),
    );
  }

Widget _buildAnimatedContentItem(
    BuildContext context, Content item, Color color) {
  return GestureDetector(
    onTap: () {
      if (item.type == "map") {
        launchUrl(Uri.parse(item.filePath)); // For map links
      } else if (item.type == "pdf") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PDFViewerPage(
              content: item,
              pdfLink: item.pdfLink,
              pdfLinkText: item.pdfLinkText,
            ),
          ),
        );
      } else if (item.type == "phone") {
        _launchPhoneNumber(item.phoneNumber!, context); // Pass context here
      } else if (item.type == "email" && item.emailAddress != null) {
        _launchEmailApp(item.emailAddress!); // For email address
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerPage(content: item),
          ),
        );
      }
    },
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
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
          title: Text(
            item.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          trailing: item.type == "email"
              ? const Icon(Icons.email, color: Colors.black) // Show email icon
              : item.type == "phone"
                  ? const Icon(Icons.phone, color: Colors.black) // Show phone icon
                  : item.type == "map"
                      ? item.filePath.contains("maps")
                          ? const Icon(Icons.pin_drop, color: Colors.black) // Show map pin icon
                          : const Icon(Icons.link, color: Colors.black) // Show link icon
                      : item.type == "pdf"
                          ? const Icon(Icons.picture_as_pdf, color: Colors.black) // Show PDF icon
                          : item.type == "video"
                              ? const Icon(Icons.videocam, color: Colors.black) // Show video icon
                              : item.type == "audio"
                                  ? const Icon(Icons.audiotrack, color: Colors.black) // Show audio icon
                                  : const Icon(Icons.help_outline, color: Colors.black), // Default icon for unknown types
        ),
      ),
    ),
  );
}

void _launchPhoneNumber(String phoneNumber, BuildContext context) async {
  final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

  try {
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      // If it can't launch the phone app, show a dialog with instructions
      throw 'Could not launch phone number $phoneNumber';
    }
  } catch (e) {
    // Check if context is still valid before showing the dialog
    // ignore: use_build_context_synchronously
    if (Navigator.canPop(context)) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Phone Number Issue"),
            content: Text(
              '''We couldn't open the phone app, but the phone number is $phoneNumber. You can write it down and dial it manually. 
              
Nous n'avons pas pu ouvrir l'application téléphonique, mais le numéro de téléphone est $phoneNumber. Vous pouvez le noter et le composer manuellement. ''',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}

  void _launchEmailApp(String emailAddress) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch email client for $emailAddress';
    }
  }
}

// VIDEO AND AUDIO PLAYER

// Main Player page
class PlayerPage extends StatefulWidget {
  final Content content;

  const PlayerPage({required this.content, super.key});

  @override
  PlayerPageState createState() => PlayerPageState();
}

class PlayerPageState extends State<PlayerPage> {
  AudioPlayer? _audioPlayer;
  VideoPlayerController? _videoController;
  bool isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final isLocal = !widget.content.filePath.startsWith("assets/");

    if (widget.content.type == "audio") {
      _audioPlayer = AudioPlayer();
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration.music());
      if (isLocal) {
        await _audioPlayer!.setFilePath(widget.content.filePath);
      } else {
        await _audioPlayer!.setAsset(widget.content.filePath);
      }
      _audioPlayer!.durationStream.listen((duration) {
        setState(() {
          _totalDuration = duration ?? Duration.zero;
        });
      });
      _audioPlayer!.positionStream.listen((position) {
        setState(() {
          _currentPosition = position;
        });
      });
    } else if (widget.content.type == "video") {
      _videoController = isLocal
          ? VideoPlayerController.file(File(widget.content.filePath))
          : VideoPlayerController.asset(widget.content.filePath);

      await _videoController!.initialize();
      setState(() {
        _totalDuration = _videoController!.value.duration;
      });
      _videoController!.addListener(() {
        setState(() {
          _currentPosition = _videoController!.value.position;
        });
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _seekAudio(Duration position) => _audioPlayer?.seek(position);
  void _seekVideo(Duration position) => _videoController?.seekTo(position);

  void _togglePlayPause() {
    setState(() {
      if (widget.content.type == "audio") {
        isPlaying ? _audioPlayer?.pause() : _audioPlayer?.play();
      } else if (widget.content.type == "video") {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
        } else {
          _videoController!.play();
        }
      }
      isPlaying = !isPlaying;
    });
  }

  void _goToFullScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenPlayer(content: widget.content),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,
        title: Text(widget.content.title),
        actions: widget.content.type == "video"
            ? [
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: () => _goToFullScreen(context),
          )
        ]
            : null,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              if (widget.content.type == "audio") ...[
                Expanded(
                  child: Center(
                    child: widget.content.coverImagePath != null
                        ? Image.asset(widget.content.coverImagePath!)
                        : Image.asset(
                      "assets/icons/audio_placeholder.png",
                      height: 200,
                      width: 200,
                    ),
                  ),
                ),
              ],
              if (widget.content.type == "video" && _videoController != null && _videoController!.value.isInitialized) ...[
                Flexible(
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Row(
                  children: [
                    Text(formatDuration(_currentPosition)),
                    Expanded(
                      child: Slider(
                        value: _currentPosition.inSeconds.toDouble(),
                        max: _totalDuration.inSeconds.toDouble(),
                        onChanged: (value) {
                          final newPosition = Duration(seconds: value.toInt());
                          widget.content.type == "audio"
                              ? _seekAudio(newPosition)
                              : _seekVideo(newPosition);
                        },
                      ),
                    ),
                    Text(formatDuration(_totalDuration)),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_10),
                    iconSize: 30,
                    onPressed: () {
                      final newPosition = _currentPosition - const Duration(seconds: 10);
                      widget.content.type == "audio"
                          ? _seekAudio(newPosition)
                          : _seekVideo(newPosition);
                    },
                  ),
                  IconButton(
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    iconSize: 40,
                    onPressed: _togglePlayPause,
                  ),
                  IconButton(
                    icon: const Icon(Icons.forward_10),
                    iconSize: 30,
                    onPressed: () {
                      final newPosition = _currentPosition + const Duration(seconds: 10);
                      widget.content.type == "audio"
                          ? _seekAudio(newPosition)
                          : _seekVideo(newPosition);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      favoriteContents.contains(widget.content)
                          ? Icons.star
                          : Icons.star_border,
                    ),
                    iconSize: 30,
                    onPressed: () {
                      setState(() {
                        if (favoriteContents.contains(widget.content)) {
                          favoriteContents.remove(widget.content);
                        } else {
                          favoriteContents.add(widget.content);
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Ajouter ce media aux favoris",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}


// FULLSCREEN VIDEO PLAYER
class FullScreenPlayer extends StatefulWidget {
  final Content content;

  const FullScreenPlayer({required this.content, super.key});

  @override
  FullScreenPlayerState createState() => FullScreenPlayerState();
}

class FullScreenPlayerState extends State<FullScreenPlayer> {
  late final VideoPlayerController _videoController;
  bool isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _controlsVisible = true; // Variable to track visibility of controls
  // ignore: unused_field
  late DeviceOrientation _initialOrientation;
  late Timer _hideControlsTimer; // Timer to hide controls automatically

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset(widget.content.filePath)
      ..initialize().then((_) {
        setState(() {
          _totalDuration = _videoController.value.duration;
        });
        _videoController.addListener(() {
          setState(() {
            _currentPosition = _videoController.value.position;
          });
        });
      });

    // Lock to landscape mode when fullscreen is enabled
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _hideControlsTimer = Timer.periodic(const Duration(seconds: 7), (timer) {   // Hide controls after 7 seconds
      if (_controlsVisible) {
        setState(() {
          _controlsVisible = false;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initialOrientation =
        MediaQuery.of(context).orientation == Orientation.portrait
            ? DeviceOrientation.portraitUp
            : DeviceOrientation.landscapeRight;
  }

  @override
  void dispose() {
    _videoController.dispose();
    _hideControlsTimer.cancel();
    // Unlock rotation after exiting fullscreen, and return to original state
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _seekVideo(Duration position) {
    _videoController.seekTo(position);
  }

  void _togglePlayPause() {
    setState(() {
      if (_videoController.value.isPlaying) {
        _videoController.pause();
      } else {
        _videoController.play();
      }
      isPlaying = !isPlaying;
    });
  }

  void _toggleControls() {
    setState(() {
      _controlsVisible = !_controlsVisible;
    });

    // Reset the hide controls timer each time the controls are shown
    if (_controlsVisible) {
      _hideControlsTimer.cancel();
      _hideControlsTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (_controlsVisible) {
          setState(() {
            _controlsVisible = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _toggleControls, // Toggle controls visibility on tap
        child: Stack(
          children: [
            Center(
              child: _videoController.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _videoController.value.aspectRatio,
                      child: VideoPlayer(_videoController),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
            Positioned(
              top: 30,
              left: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05), // Light semi-transparent backdrop
                  borderRadius: BorderRadius.circular(30), // Slightly round corners for the backdrop
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context); // Close fullscreen and return to previous state
                  },
                ),
              ),
            ),
            if (_controlsVisible) // Only show the controls if _controlsVisible is true
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Rectangular container around all the three icons
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.05), // Light backdrop
                              borderRadius: BorderRadius.circular(8), // Slightly rounded corners for the rectangular container
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.replay_10, color: Colors.white),
                                  iconSize: 30,
                                  onPressed: () {
                                    final newPosition = _currentPosition - const Duration(seconds: 10);
                                    _seekVideo(newPosition);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                                  iconSize: 40,
                                  onPressed: _togglePlayPause,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.forward_10, color: Colors.white),
                                  iconSize: 30,
                                  onPressed: () {
                                    final newPosition = _currentPosition + const Duration(seconds: 10);
                                    _seekVideo(newPosition);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _currentPosition.inSeconds.toDouble(),
                        max: _totalDuration.inSeconds.toDouble(),
                        onChanged: (value) {
                          final newPosition = Duration(seconds: value.toInt());
                          _seekVideo(newPosition);
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// PDF Viewer Page
class PDFViewerPage extends StatefulWidget {
  final Content content; // Add Content as a parameter
  final String? pdfLink; // optional parameter for the link
  final String? pdfLinkText; // optional parameter for the link text

  const PDFViewerPage({
    required this.content, // Accept content as a parameter
    this.pdfLink,
    this.pdfLinkText,
    super.key,
  });

  @override
  PDFViewerPageState createState() => PDFViewerPageState();
}

class PDFViewerPageState extends State<PDFViewerPage> {
  bool _isLoading = true;
  String? _localPath;
  late PDFViewController pdfViewController;
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isFavorite = false;

  // Audio players
  AudioPlayer? _audioPlayerFR;
  AudioPlayer? _audioPlayerEN;
  bool _isPlaying = false;
  String _currentLanguage = "fr";

  @override
  void initState() {
    super.initState();
    _loadPdf(widget.content.filePath);
    _checkIfFavorite();
    // Initialize the audio players
    _initializeAudioPlayers();
  }

  Future<void> _loadPdf(String path) async {
    try {
      String finalPath;

      if (path.startsWith('assets/')) {
        // Le fichier vient des assets
        final byteData = await rootBundle.load(path);
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/${path.split('/').last}');
        await file.writeAsBytes(byteData.buffer.asUint8List());
        finalPath = file.path;
      } else {
        // Le fichier vient d'un chemin local (file picker)
        final file = File(path);
        if (!await file.exists()) throw Exception("Fichier introuvable !");
        finalPath = file.path;
      }

      setState(() {
        _localPath = finalPath;
        _isLoading = false;
      });
    } catch (e) {
      _showErrorDialog(context, "Erreur lors du chargement du PDF: $e");
    }
  }

  // Initialize the audio players
  void _initializeAudioPlayers() {
    if (widget.content.audioPathFR != null) {
      _audioPlayerFR = AudioPlayer();
      _audioPlayerFR?.setAsset(widget.content.audioPathFR!);
    }
    if (widget.content.audioPathEN != null) {
      _audioPlayerEN = AudioPlayer();
      _audioPlayerEN?.setAsset(widget.content.audioPathEN!);
    }
  }

  // Pauses all audio playback immediately
  void _stopAllAudio() {
    _audioPlayerFR?.pause();
    _audioPlayerEN?.pause();

    setState(() {
      _isPlaying = false;
    });
  }

  // Handle both play and pause actions
  void _togglePlayPause() {
    if (_isPlaying) {
      _stopAllAudio();
    } else {
      if (_currentLanguage == "fr") {
        _audioPlayerFR?.play();
        setState(() {
          _isPlaying = true;
        });
      }
      if (_currentLanguage == "en") {
        _audioPlayerEN?.play();
        setState(() {
          _isPlaying = true;
        });
      }
    }
  }

  // Start the French audio from the beginning
  void _startAudioFR() {
    _stopAllAudio();
    setState(() {
      if (_audioPlayerFR != null) {
        _audioPlayerFR?.seek(Duration.zero); // Start from the beginning
        _audioPlayerFR?.play();
        _isPlaying = true;
        _currentLanguage = "fr";
      }
    });
  }

  // Start the English audio from the beginning
  void _startAudioEN() {
    _stopAllAudio();
    setState(() {
      if (_audioPlayerEN != null) {
        _audioPlayerEN?.seek(Duration.zero); // Start from the beginning
        _audioPlayerEN?.play();
        _currentLanguage = "en";
        _isPlaying = true;
      }
    });
  }

  // Check if the PDF is already in the favorites list
  void _checkIfFavorite() {
    final favorite = favoriteContents
        .any((item) => item.filePath == widget.content.filePath);
    setState(() {
      _isFavorite = favorite;
    });
  }

  // Toggle the favorite status of the PDF
  void _toggleFavorite() {
    setState(() {
      if (_isFavorite) {
        favoriteContents
            .removeWhere((item) => item.filePath == widget.content.filePath);
      } else {
        favoriteContents.add(Content(
          title: widget.content.title, // Use the title from the Content object
          type: 'pdf',
          filePath: widget.content.filePath,
          audioPathFR: widget.content.audioPathFR,
          audioPathEN: widget.content.audioPathEN,
          pdfLink: widget.content.pdfLink,
          pdfLinkText: widget.content.pdfLinkText,
        ));
      }
      _isFavorite = !_isFavorite;
      saveFavorites(); // Save the updated favorites list
    });
  }

  @override
  void dispose() {
    // Dispose of audio players when the page is disposed
    _audioPlayerFR?.dispose();
    _audioPlayerEN?.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      actions: [
        Row(
          children: [
            if (_audioPlayerFR != null)
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/france.svg', // Path to the French flag SVG
                  height: 24,
                ),
                onPressed: () {
                  _startAudioFR();
                },
              ),
            if (_audioPlayerEN != null)
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/uk.svg', // Path to the UK flag SVG
                  height: 24,
                ),
                onPressed: () {
                  _startAudioEN();
                },
              ),
            if (_audioPlayerFR != null || _audioPlayerEN != null)
              const Icon(
                Icons.headset,
                size: 24,
                color: Colors.black,
              ),
            if (widget.content.audioPathEN != null ||
                widget.content.audioPathFR != null)
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.black,
                ),
                onPressed: _togglePlayPause,
              ),
          ],
        ),
        const SizedBox(width: 40),
        if (_totalPages > 0)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                "${_currentPage + 1} / $_totalPages",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.star : Icons.star_border,
            color: Colors.black,
          ),
          onPressed: _toggleFavorite,
        ),
      ],
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              PDFView(
                filePath: _localPath,
                enableSwipe: true,
                swipeHorizontal: false,
                autoSpacing: true,
                pageFling: true,
                onRender: (pages) {
                  setState(() {
                    _totalPages = pages ?? 0;
                  });
                },
                onViewCreated: (PDFViewController controller) {
                  pdfViewController = controller;
                },
                onPageChanged: (page, total) {
                  setState(() {
                    _currentPage = page ?? 0;
                  });
                },
                onError: (error) {
                  if (mounted) {
                    _showErrorDialog(context, "Error displaying PDF: $error");
                  }
                },
                onPageError: (page, error) {
                  if (mounted) {
                    _showErrorDialog(context, "Error on page $page: $error");
                  }
                },
              ),
              // Display the clickable link at the top
              if (widget.pdfLink != null && widget.pdfLinkText != null)
                Positioned(
                  top: 10, // Positioning the link at the top
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    color: Colors.black.withOpacity(0.8), // Dark background for visibility
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text(
                            widget.pdfLinkText!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0, // Larger font size for better visibility
                              fontWeight: FontWeight.bold, // Make it bold
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () async {
                              if (await canLaunchUrl(Uri.parse(widget.pdfLink!))) {
                                await launchUrl(Uri.parse(widget.pdfLink!));
                              } else {
                                throw 'Could not launch ${widget.pdfLink}';
                              }
                            },
                            child: Text(
                              widget.pdfLink!,
                              style: const TextStyle(
                                color: Colors.blueAccent, // Brighter color for the link
                                fontSize: 16.0, // Larger font size
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold, // Bold link text
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
  );
}

  // Error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}



