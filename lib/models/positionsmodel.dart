class PositionsModel {
  final String title;
  final String description;
  final String image;
  final String full_description;

  PositionsModel({
    required this.title,
    required this.description,
    required this.image,
    required this.full_description,
  });

  factory PositionsModel.fromJson(Map<String, dynamic> json) {
    return PositionsModel(
      title: json['title'],
      description: json['description'],
      image: json['image'],
      full_description: json['full_description'],
    );
  }
}
