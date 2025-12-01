class PlayerSkills {
  final String title;
  final String description;
  final String image;
  final String full_description;

  PlayerSkills({
    required this.title,
    required this.description,
    required this.image,
    required this.full_description,
  });

  factory PlayerSkills.fromJson(Map<String, dynamic> json) {
    return PlayerSkills(
      title: json['title'],
      description: json['description'],
      image: json['image'],
      full_description: json['full_description'],
    );
  }
}
