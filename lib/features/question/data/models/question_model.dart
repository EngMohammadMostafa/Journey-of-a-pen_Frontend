import 'answer_model.dart';

class QuestionModel {
  final int id;
  final String question; // من question_text
  final List<AnswerModel> answers;

  QuestionModel({
    required this.id,
    required this.question,
    required this.answers,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? 0,
      question: json['question_text'] ?? '', // إذا جاء null تصبح سلسلة فارغة
      answers: (json['answers'] as List<dynamic>?)
          ?.map((a) => AnswerModel.fromJson(a))
          .toList() ??
          [], // إذا null تصبح قائمة فارغة
    );
  }
}
