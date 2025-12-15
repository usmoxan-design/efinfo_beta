import 'package:efinfo_beta/data/formationsdata.dart';

class Formation {
  final String name;
  final String title;
  final String warning;
  final String subtitle;
  final String description;
  final String bestFor;
  final String playerRecommendations;
  final List<List<double>> positions; // [x, y]
  final Difficulty difficulty;

  const Formation({
    required this.name,
    required this.title,
    required this.warning,
    required this.subtitle,
    required this.description,
    required this.bestFor,
    required this.playerRecommendations,
    required this.positions,
    this.difficulty = Difficulty.medium,
  });
}
