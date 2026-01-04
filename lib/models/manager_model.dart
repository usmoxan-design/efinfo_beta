class Manager {
  final String name;
  final String fullName;
  final String team;
  final String nationality;
  final String type;
  final int age;
  final String coachingAffinity;
  final Map<String, int> teamPlaystyle;
  final String imageUrl;

  Manager({
    required this.name,
    required this.fullName,
    required this.team,
    required this.nationality,
    required this.type,
    required this.age,
    required this.coachingAffinity,
    required this.teamPlaystyle,
    required this.imageUrl,
  });

  factory Manager.fromJson(Map<String, dynamic> json) {
    return Manager(
      name: json['name'] ?? '',
      fullName: json['fullName'] ?? '',
      team: json['team'] ?? '',
      nationality: json['nationality'] ?? '',
      type: json['type'] ?? '',
      age: json['age'] is String
          ? int.tryParse(json['age']) ?? 0
          : json['age'] ?? 0,
      coachingAffinity: json['coachingAffinity'] ?? '',
      teamPlaystyle: Map<String, int>.from(json['teamPlaystyle'] ?? {}),
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'fullName': fullName,
      'team': team,
      'nationality': nationality,
      'type': type,
      'age': age,
      'coachingAffinity': coachingAffinity,
      'teamPlaystyle': teamPlaystyle,
      'imageUrl': imageUrl,
    };
  }
}
