class PlayingStyle {
  final String title;
  final String description;
  final String compatiblePositions;
  final String data;

  PlayingStyle({
    required this.title,
    required this.description,
    required this.compatiblePositions,
    required this.data,
  });

  factory PlayingStyle.fromJson(Map<String, dynamic> json) {
    return PlayingStyle(
      title: json['title'],
      description: json['description'],
      compatiblePositions: json['compatible_positions'],
      data: json['data'],
    );
  }
}
