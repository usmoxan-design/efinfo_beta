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
        if (key.startsWith('assets/images/quiz/') && key.endsWith('.png')) {
          // Format: assets/images/quiz/Country - League/Club.png
          // key parts: [assets, images, quiz, Country - League, Club.png]
          var parts = key.split('/');
          if (parts.length >= 5) {
            String folderName = parts[3]; // "Country - League"
            String fileName = parts[4]; // "Club.png"

            String clubName = fileName.replaceAll('.png', '');
            String league = folderName;

            _allClubs.add({
              'league': league,
              'club': clubName,
              'path': key,
            });
          }
        }
      }
      print("QuizData: Loaded ${_allClubs.length} clubs.");
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

    if (league != null && league != "All") {
      filteredData = _allClubs.where((e) => e['league'] == league).toList();
    }

    // If we don't have enough data for the requested count, just take what we have
    // But we also need wrong answers.
    if (filteredData.isEmpty) return [];

    var data = List<Map<String, String>>.from(filteredData)..shuffle();

    for (var item in data.take(count)) {
      String clubName = item['club']!;
      String itemLeague = item['league']!;
      String path = item['path']!;

      // Generate options
      List<String> options = [clubName];

      // Get other clubs for wrong answers.
      // Prefer same league if possible, otherwise any.
      var sameLeagueOptions = _allClubs
          .where((e) => e['league'] == itemLeague && e['club'] != clubName)
          .map((e) => e['club']!)
          .toList()
        ..shuffle();

      var otherOptions = _allClubs
          .where((e) => e['league'] != itemLeague) // Just backup
          .map((e) => e['club']!)
          .toList()
        ..shuffle();

      if (sameLeagueOptions.length >= 3) {
        options.addAll(sameLeagueOptions.take(3));
      } else {
        options.addAll(sameLeagueOptions);
        options.addAll(otherOptions.take(3 - sameLeagueOptions.length));
      }

      options.shuffle();

      questions.add(QuizQuestion(
        imageUrl: path,
        correctAnswer: clubName,
        options: options,
        league: itemLeague,
      ));
    }
    return questions;
  }
}
