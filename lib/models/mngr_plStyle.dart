class PlayingStyle {
  final String title;
  final String description;
  final String data;

  PlayingStyle({
    required this.title,
    required this.description,
    required this.data,
  });

  factory PlayingStyle.fromJson(Map<String, dynamic> json) {
    return PlayingStyle(
      title: json['title'],
      description: json['description'],
      data: json['data'],
    );
  }
}
