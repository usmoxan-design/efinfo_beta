class TBuilderPlayer {
  final String id;
  final String name;
  final String position;
  final int rating;
  final String team;
  final String imageUrl;

  TBuilderPlayer({
    required this.id,
    required this.name,
    required this.position,
    required this.rating,
    required this.team,
    required this.imageUrl,
  });

  // JSON dan modelga o'tkazish konstruktori (qo'shildi)
  factory TBuilderPlayer.fromJson(Map<String, dynamic> json) {
    return TBuilderPlayer(
      id: json['id'] as String,
      name: json['name'] as String,
      position: json['position'] as String,
      rating: json['rating'] as int,
      team: json['team'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }
}
