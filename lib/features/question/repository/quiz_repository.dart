import 'dart:convert';
import 'package:book_worm_haven/core/api/api_service.dart';
import '../data/models/question_model.dart';

class QuizRepository {
  final ApiService _api;

  QuizRepository(this._api);

  // =============================
  //  جلب أسئلة كتاب
  // =============================
  Future<List<QuestionModel>> fetchQuestions(int bookId) async {
    final response = await _api.get('/books/$bookId/questions');

    final raw = response.data;
    final Map<String, dynamic> data =
    raw is String ? jsonDecode(raw) : Map<String, dynamic>.from(raw);

    final questions = data['questions'] as List;

    return questions.map((q) => QuestionModel.fromJson(q)).toList();
  }

  // =============================
  //  إرسال إجابة واحدة
  // =============================
  Future<Map<String, dynamic>> submitAnswer({
    required int bookId,
    required int questionId,
    required int answerId,
  }) async {
    final response = await _api.post(
      '/books/$bookId/session/submit',
      data: {
        'answers': [
          {'question_id': questionId, 'answer_id': answerId}
        ]
      },
    );

    final raw = response.data;
    return raw is String ? jsonDecode(raw) : Map<String, dynamic>.from(raw);
  }

  // =============================
  //  إنهاء الجلسة
  // =============================
  Future<Map<String, dynamic>> finishSession(int bookId) async {
    final response = await _api.post(
      '/books/$bookId/session/submit',
    );

    final raw = response.data;
    return raw is String ? jsonDecode(raw) : Map<String, dynamic>.from(raw);
  }
}
