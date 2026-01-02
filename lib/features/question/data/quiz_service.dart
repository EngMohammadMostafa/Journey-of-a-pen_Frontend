import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/api/api_service.dart';
import 'models/question_model.dart';
import 'models/answer_model.dart';

class QuizService {
  final ApiService _api;
  ApiService get api => _api;

  QuizService(this._api);

  // جلب أسئلة كتاب
  Future<List<QuestionModel>> fetchQuestions(int bookId) async {
    final response = await _api.get('/books/$bookId/questions');

    final data = response.data as Map<String, dynamic>;
    final questionsList = data['questions'] as List<dynamic>;

    return questionsList.map((json) => QuestionModel.fromJson(json)).toList();
  }

  // حفظ إجابة سؤال واحد
  Future<bool> submitAnswer({
    required int bookId,
    required int questionId,
    required int answerId,
  }) async {
    final response = await _api.post(
      '/books/$bookId/session/submit',
      data: {
        "answers": [
          {
            "question_id": questionId,
            "answer_id": answerId,
          }
        ]
      },
    );

    return response.statusCode == 201 || response.statusCode == 200;
  }

  // حفظ كل الإجابات دفعة واحدة
  Future<bool> submitAnswersBulk({
    required int bookId,
    required List<Map<String, int>> answers,
  }) async {
    final response = await _api.post(
      '/books/$bookId/session/submit',
      data: {
        "answers": answers,
      },
    );

    return response.statusCode == 201 || response.statusCode == 200;
  }

  // إنهاء الجلسة
  Future<Map<String, dynamic>> finishSession(int bookId) async {
    final response = await _api.post('/books/$bookId/session/finish');

    return response.data as Map<String, dynamic>;
  }
}
