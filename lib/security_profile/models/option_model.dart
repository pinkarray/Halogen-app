class OptionModel {
  final String id;
  final String label;
  final double score;

  OptionModel({
    required this.id,
    required this.label,
    required this.score,
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      id: json['id'],
      label: json['label'],
      score: (json['score'] as num).toDouble(),
    );
  }
}