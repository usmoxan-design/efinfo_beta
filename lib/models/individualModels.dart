class IndividualModel {
  final String title;
  final String instruction;
  final String description;
  final String data;

  IndividualModel({
    required this.title,
    required this.instruction,
    required this.description,
    required this.data,
  });

  factory IndividualModel.fromJson(Map<String, dynamic> json) {
    return IndividualModel(
      title: json['title'],
      instruction: json['instruction'],
      description: json['description'],
      data: json['data'],
    );
  }
}
