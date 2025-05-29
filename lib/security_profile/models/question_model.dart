import 'option_model.dart';

class QuestionModel {
  final String id;
  final String question;
  final String type;
  final String refCode;
  final String baseCode;
  final String? groupLabel;
  final String? answerModule;
  final List<OptionModel> options; 

  QuestionModel({
    required this.id,
    required this.question,
    required this.type,
    required this.refCode,
    required this.baseCode,
    this.groupLabel,
    this.answerModule,
    this.options = const [], 
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'],
      question: json['question'],
      type: json['type'],
      refCode: json['ref_code'],
      baseCode: json['base_code'],
      groupLabel: json['group_label'],
      answerModule: json['answer_module'],
      options: (json['options'] as List<dynamic>?)
              ?.map((o) => OptionModel.fromJson(o))
              .toList() ??
          [],
    );
  }
  factory QuestionModel.empty() {
    return QuestionModel(
      id: '',
      question: '',
      type: '',
      refCode: '',
      baseCode: '',
      groupLabel: null,
      answerModule: null,
      options: [],
    );
  }
}