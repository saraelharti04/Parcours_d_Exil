import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UpcomingEventsPage extends StatefulWidget {
  final ValueNotifier<bool> hasNewActivityNotifier;

  const UpcomingEventsPage({super.key, required this.hasNewActivityNotifier});

  @override
  State<UpcomingEventsPage> createState() => _UpcomingEventsPageState();
}

class _UpcomingEventsPageState extends State<UpcomingEventsPage> {
  List<dynamic> _activities = [];
  String? _userGenre;
  bool _isLoading = true;
  String _errorMessage = '';

  final List<Color> _cardColors = [
    Colors.amber.shade100,
    Colors.pink.shade100,
    Colors.purple.shade100,
    Colors.cyan.shade100,
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkForNewActivity();
  }

  Future<void> _checkForNewActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final hasNew = prefs.getBool('has_new_activity') ?? false;

    if (hasNew) {
      // Marquer comme vu
      await prefs.setBool('has_new_activity', false);
    }

    // Mettre à jour la pastille (même si elle est fausse)
    widget.hasNewActivityNotifier.value = false;
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userId = prefs.getString('user_id');

    if (token == null || userId == null) {
      setState(() {
        _errorMessage = 'Utilisateur non connecté';
        _isLoading = false;
      });
      return;
    }

    try {
      // 🔹 Récupérer le profil utilisateur pour connaître son genre
      final userResponse = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (userResponse.statusCode != 200) {
        setState(() {
          _errorMessage = 'Erreur lors du chargement du profil';
          _isLoading = false;
        });
        return;
      }

      final userData = jsonDecode(userResponse.body);
      final userGenre = userData['genre'];
      _userGenre = userGenre;

      // 🔹 Récupérer toutes les activités
      final activitiesResponse = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/activities'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final allActivities = jsonDecode(activitiesResponse.body) as List;
      final now = DateTime.now();

      // 🔹 Filtrer activités futures correspondant au genre du patient
      final upcomingFiltered = allActivities.where((activity) {
        final date = DateTime.tryParse(activity['date'] ?? '') ?? DateTime(2000);
        final genre = activity['genre'] ?? 'Tous';
        final isFuture = date.isAfter(now);
        final genreMatches = userGenre == 'Autre' || genre == 'Tous' || genre == userGenre;
        return isFuture && genreMatches;
      }).toList();

      // 🔹 Trier par date croissante
      upcomingFiltered.sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));

      if (_activities.isNotEmpty && userId != null) {
        final newestId = _activities.first['_id'];
        await prefs.setString('last_seen_activity_id_$userId', newestId);
        widget.hasNewActivityNotifier.value = false;
      }


      setState(() {
        _activities = upcomingFiltered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion au serveur';
        _isLoading = false;
      });
    }
  }


  void _showActivityDetails(Map<String, dynamic> activity) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(activity['title'] ?? 'Activité'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📅 Date : ${activity['date']}'),
            Text('🕒 Heure : ${activity['time']}'),
            Text('👥 Réservé aux : ${activity['genre']}s'),
            const SizedBox(height: 8),
            Text('📝 Description :\n${activity['description'] ?? 'Aucune'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: const Text("Activités à venir")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : _activities.isEmpty
          ? const Center(child: Text("Aucune activité à venir"))
          : ListView.builder(
        itemCount: _activities.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final activity = _activities[index];
          final color = _cardColors[index % _cardColors.length];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: GestureDetector(
              onTap: () => _showActivityDetails(activity),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        activity['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 18),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
