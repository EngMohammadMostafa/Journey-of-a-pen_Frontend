class AnswerModel {
  final int id;
  final String answer;
  final bool isCorrect;

  AnswerModel({
    required this.id,
    required this.answer,
    this.isCorrect = false,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      id: json['id'] ?? 0,
      answer: json['answer_text'] ?? '',
      isCorrect: json['is_correct'] ?? false, // إذا null تصبح false
    );
  }
}
