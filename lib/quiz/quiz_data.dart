import 'package:flutter/services.dart';

class QuizQuestion {
  final String imageUrl;
  final String correctAnswer;
  final List<String> options;
  final String league;

  QuizQuestion({
    required this.imageUrl,
    required this.correctAnswer,
    required this.options,
    required this.league,
  });
}

class QuizData {
  static List<Map<String, String>> _allClubs = [];
  static bool _isLoaded = false;

  static Future<void> ensureLoaded() async {
    if (_isLoaded) return;

    try {
      final AssetManifest assetManifest =
          await AssetManifest.loadFromAssetBundle(rootBundle);
      final List<String> assets = assetManifest.listAssets();

      _allClubs = [];

      for (String key in assets) {
        if (key.startsWith('assets/images/players_quiz/') &&
            key.endsWith('.png')) {
          // Format: assets/images/players_quiz/Player Name.png
          var parts = key.split('/');
          if (parts.length >= 4) {
            String fileName = parts[3]; // "Player Name.png"

            String playerName = fileName.replaceAll('.png', '');
            String league = "Players"; // Default category for now

            _allClubs.add({
              'league': league,
              'club':
                  playerName, // Reusing 'club' key for player name to minimize code changes
              'path': key,
            });
          }
        }
      }
      print("QuizData: Loaded ${_allClubs.length} players.");
      _isLoaded = true;
    } catch (e) {
      print("Error loading quiz assets: $e");
    }
  }

  static List<String> getAvailableLeagues() {
    return _allClubs.map((e) => e['league']!).toSet().toList()..sort();
  }

  static List<QuizQuestion> getQuestions(int count, {String? league}) {
    List<QuizQuestion> questions = [];
    var filteredData = _allClubs;

    // For now, since everything is in 'Players' league, filtering might not be needed
    // but keeping it for compatibility.
    if (league != null && league != "All") {
      filteredData = _allClubs.where((e) => e['league'] == league).toList();
    }

    if (filteredData.isEmpty) return [];

    var data = List<Map<String, String>>.from(filteredData)..shuffle();

    for (var item in data.take(count)) {
      String playerName = item['club']!;
      String itemLeague = item['league']!;
      String path = item['path']!;

      // Generate options
      List<String> options = [playerName];

      // Get other players for wrong answers.
      var otherPlayers = _allClubs
          .where((e) => e['club'] != playerName)
          .map((e) => e['club']!)
          .toList()
        ..shuffle();

      if (otherPlayers.length >= 3) {
        options.addAll(otherPlayers.take(3));
      } else {
        options.addAll(otherPlayers);
      }

      options.shuffle();

      questions.add(QuizQuestion(
        imageUrl: path,
        correctAnswer: playerName,
        options: options,
        league: itemLeague,
      ));
    }
    return questions;
  }
}
