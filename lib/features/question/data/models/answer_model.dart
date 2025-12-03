class AnswerModel {
  final int id;
  final String answer;
  final bool? isCorrect; // null للمستخدم العادي

  AnswerModel({
    required this.id,
    required this.answer,
    this.isCorrect,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      id: json['id'] ?? 0,
      answer: json['answer_text'] ?? '', // إذا null تصبح سلسلة فارغة
      isCorrect: json['is_correct'], // يمكن أن تبقى null
    );
  }
}
