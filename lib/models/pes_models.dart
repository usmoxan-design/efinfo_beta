import 'package:flutter/material.dart';

class PesCategory {
  final String name;
  final String url;

  PesCategory({required this.name, required this.url});

  factory PesCategory.fromJson(Map<String, dynamic> json) {
    return PesCategory(
      name: json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class PesPlayer {
  final String id;
  final String name;
  final String club;
  final String nationality;
  final String ovr;
  final String position;
  final String? image;
  final String? playingStyle;

  PesPlayer({
    required this.id,
    required this.name,
    required this.club,
    required this.nationality,
    this.ovr = '0',
    this.position = 'Unknown',
    this.image,
    this.playingStyle,
  });

  factory PesPlayer.fromJson(Map<String, dynamic> json) {
    return PesPlayer(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      club: json['club'] ?? 'Free Agent',
      nationality: json['nationality'] ?? 'Unknown',
      ovr: json['ovr']?.toString() ?? '0',
      position: json['position']?.toString() ?? 'Unknown',
      image: json['image'],
      playingStyle: json['playing_style'] ?? json['playingStyle'],
    );
  }

  String get imageUrl => image ?? 'https://pesdb.net/assets/img/card/f$id.png';
  String get imageFlipUrl => 'https://pesdb.net/assets/img/card/b$id.png';
  String get imageMaxUrl => 'https://pesdb.net/assets/img/card/f${id}max.png';
  String get imageMaxFlipUrl =>
      'https://pesdb.net/assets/img/card/b${id}max.png';
}

class PesPlayerDetail {
  final PesPlayer player;
  final String position;
  final String height;
  final String age;
  final String foot;
  final Map<String, String> stats;
  final Map<String, String> info;
  final String playingStyle;
  final List<String> skills;
  final Map<String, int> suggestedPoints;
  final String description;

  PesPlayerDetail({
    required this.player,
    required this.position,
    required this.height,
    required this.age,
    required this.foot,
    required this.stats,
    this.info = const {},
    this.playingStyle = 'Unknown',
    this.skills = const [],
    this.suggestedPoints = const {},
    this.description = '',
  });

  factory PesPlayerDetail.fromJson(
      Map<String, dynamic> json, PesPlayer originalPlayer) {
    return PesPlayerDetail(
      player: json['player'] != null
          ? PesPlayer.fromJson(json['player'])
          : originalPlayer,
      position: json['position']?.toString() ?? 'Unknown',
      height: json['height']?.toString() ?? 'Unknown',
      age: json['age']?.toString() ?? 'Unknown',
      foot: json['foot']?.toString() ?? 'Unknown',
      stats: Map<String, String>.from(json['stats'] ?? {}),
      info: Map<String, String>.from(json['info'] ?? {}),
      playingStyle: json['playing_style'] ?? json['playingStyle'] ?? 'Unknown',
      skills: List<String>.from(json['skills'] ?? json['player_skills'] ?? []),
      suggestedPoints: Map<String, int>.from(
          json['suggested_points'] ?? json['suggestedPoints'] ?? {}),
      description: json['description'] ?? '',
    );
  }
}

class PesPlayerListResult {
  final List<PesPlayer> players;
  final int totalPages;

  PesPlayerListResult({required this.players, required this.totalPages});
}

class PesFeaturedOption {
  final String name;
  final String id;

  PesFeaturedOption({required this.name, required this.id});

  factory PesFeaturedOption.fromJson(Map<String, dynamic> json) {
    return PesFeaturedOption(
      name: json['name'] ?? '',
      id: json['id']?.toString() ?? '',
    );
  }
}

class SquadFormation {
  final String name;
  final Map<String, Offset>
      positions; // Position name -> Normalized Offset (0.0 to 1.0)

  SquadFormation({required this.name, required this.positions});

  // Futbol formasi uchun professional joylashuvlar
  static List<SquadFormation> get defaults => [
        SquadFormation(name: '4-3-3', positions: {
          'GK': const Offset(0.50, 0.94),
          'LB': const Offset(0.12, 0.82),
          'CB1': const Offset(0.35, 0.82),
          'CB2': const Offset(0.65, 0.82),
          'RB': const Offset(0.88, 0.82),
          'DMF': const Offset(0.50, 0.68),
          'CMF1': const Offset(0.32, 0.50),
          'CMF2': const Offset(0.68, 0.50),
          'LWF': const Offset(0.15, 0.18),
          'RWF': const Offset(0.85, 0.18),
          'CF': const Offset(0.50, 0.18),
        }),
        SquadFormation(name: '4-4-2', positions: {
          'GK': const Offset(0.50, 0.94),
          'LB': const Offset(0.12, 0.82),
          'CB1': const Offset(0.35, 0.82),
          'CB2': const Offset(0.65, 0.82),
          'RB': const Offset(0.88, 0.82),
          'LMF': const Offset(0.15, 0.50),
          'LCM': const Offset(0.38, 0.50),
          'RCM': const Offset(0.62, 0.50),
          'RMF': const Offset(0.85, 0.50),
          'CF1': const Offset(0.38, 0.18),
          'CF2': const Offset(0.62, 0.18),
        }),
        SquadFormation(name: '4-2-1-3', positions: {
          'GK': const Offset(0.50, 0.94),
          'LB': const Offset(0.12, 0.82),
          'CB1': const Offset(0.35, 0.82),
          'CB2': const Offset(0.65, 0.82),
          'RB': const Offset(0.88, 0.82),
          'DMF1': const Offset(0.35, 0.68),
          'DMF2': const Offset(0.65, 0.68),
          'AMF': const Offset(0.50, 0.35),
          'LWF': const Offset(0.15, 0.18),
          'RWF': const Offset(0.85, 0.18),
          'CF': const Offset(0.50, 0.18),
        }),
        SquadFormation(name: '4-3-1-2', positions: {
          'GK': const Offset(0.50, 0.94),
          'LB': const Offset(0.12, 0.82),
          'CB1': const Offset(0.35, 0.82),
          'CB2': const Offset(0.65, 0.82),
          'RB': const Offset(0.88, 0.82),
          'LCM': const Offset(0.32, 0.50),
          'CDM': const Offset(0.50, 0.68),
          'RCM': const Offset(0.68, 0.50),
          'AMF': const Offset(0.50, 0.35),
          'CF1': const Offset(0.38, 0.18),
          'CF2': const Offset(0.62, 0.18),
        }),
        SquadFormation(name: '5-3-2', positions: {
          'GK': const Offset(0.50, 0.94),
          'LWB': const Offset(0.12, 0.82),
          'CB1': const Offset(0.32, 0.82),
          'CB2': const Offset(0.50, 0.82),
          'CB3': const Offset(0.68, 0.82),
          'RWB': const Offset(0.88, 0.82),
          'CMF1': const Offset(0.30, 0.50),
          'CMF2': const Offset(0.50, 0.50),
          'CMF3': const Offset(0.70, 0.50),
          'CF1': const Offset(0.40, 0.18),
          'CF2': const Offset(0.60, 0.18),
        }),
        SquadFormation(name: '4-2-2-2', positions: {
          'GK': const Offset(0.50, 0.94),
          'LB': const Offset(0.12, 0.82),
          'CB1': const Offset(0.35, 0.82),
          'CB2': const Offset(0.65, 0.82),
          'RB': const Offset(0.88, 0.82),
          'DMF1': const Offset(0.35, 0.68),
          'DMF2': const Offset(0.65, 0.68),
          'AMF1': const Offset(0.35, 0.35),
          'AMF2': const Offset(0.65, 0.35),
          'CF1': const Offset(0.40, 0.18),
          'CF2': const Offset(0.60, 0.18),
        }),
        SquadFormation(name: '5-2-1-2', positions: {
          'GK': const Offset(0.50, 0.94),
          'LWB': const Offset(0.12, 0.82),
          'CB1': const Offset(0.32, 0.82),
          'CB2': const Offset(0.50, 0.82),
          'CB3': const Offset(0.68, 0.82),
          'RWB': const Offset(0.88, 0.82),
          'DMF1': const Offset(0.35, 0.68),
          'DMF2': const Offset(0.65, 0.68),
          'AMF': const Offset(0.50, 0.35),
          'CF1': const Offset(0.40, 0.18),
          'CF2': const Offset(0.60, 0.18),
        }),
        SquadFormation(name: '4-2-4', positions: {
          'GK': const Offset(0.50, 0.94),
          'LB': const Offset(0.12, 0.82),
          'CB1': const Offset(0.35, 0.82),
          'CB2': const Offset(0.65, 0.82),
          'RB': const Offset(0.88, 0.82),
          'CMF1': const Offset(0.38, 0.50),
          'CMF2': const Offset(0.62, 0.50),
          'LWF': const Offset(0.15, 0.18),
          'LCF': const Offset(0.38, 0.18),
          'RCF': const Offset(0.62, 0.18),
          'RWF': const Offset(0.85, 0.18),
        }),
      ];
}

class SavedSquad {
  final String name;
  final String formationName;
  final Map<String, PesPlayer?> players;

  SavedSquad({
    required this.name,
    required this.formationName,
    required this.players,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'formationName': formationName,
      'players': players.map((k, v) => MapEntry(k, v?.id)),
    };
  }
}
