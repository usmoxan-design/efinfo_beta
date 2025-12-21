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

  PesPlayer({
    required this.id,
    required this.name,
    required this.club,
    required this.nationality,
  });

  factory PesPlayer.fromJson(Map<String, dynamic> json) {
    return PesPlayer(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      club: json['club'] ?? 'Free Agent',
      nationality: json['nationality'] ?? 'Unknown',
    );
  }

  String get imageUrl => 'https://pesdb.net/assets/img/card/f$id.png';
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
      position: json['position'] ?? 'Unknown',
      height: json['height'] ?? 'Unknown',
      age: json['age'] ?? 'Unknown',
      foot: json['foot'] ?? 'Unknown',
      stats: Map<String, String>.from(json['stats'] ?? {}),
      info: Map<String, String>.from(json['info'] ?? {}),
      playingStyle: json['playingStyle'] ?? 'Unknown',
      skills: List<String>.from(json['skills'] ?? []),
      suggestedPoints: Map<String, int>.from(json['suggestedPoints'] ?? {}),
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
