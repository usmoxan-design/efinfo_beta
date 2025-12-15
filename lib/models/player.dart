class Player {
  final String id;
  final String name;
  final String team;  // Masalan, 'KOC', 'FB'
  final String position;  // 'GK', 'DEF', 'MID', 'FWD'
  final int rating;
  final String imageUrl;  // Karta rasmi URL

  Player({
    required this.id,
    required this.name,
    required this.team,
    required this.position,
    required this.rating,
    required this.imageUrl,
  });
}