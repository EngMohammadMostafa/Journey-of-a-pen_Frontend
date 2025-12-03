import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/question_model.dart';
import '../repository/quiz_repository.dart';

class QuizProvider extends ChangeNotifier {
  final QuizRepository _quizRepo;

  QuizProvider(this._quizRepo);

  List<QuestionModel> _questions = [];
  int _currentIndex = 0;

  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isSessionFinished = false;

  int _totalPoints = 0;

  List<QuestionModel> get questions => _questions;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get isSessionFinished => _isSessionFinished;
  int get totalPoints => _totalPoints;

  QuestionModel? get currentQuestion =>
      _questions.isNotEmpty ? _questions[_currentIndex] : null;

  // ==========================
  // تحميل الأسئلة من السيرفر
  // ==========================
  Future<void> loadQuestions(int bookId) async {
    _isLoading = true;
    _isSessionFinished = false;
    notifyListeners();

    try {
      final list = await _quizRepo.fetchQuestions(bookId);
      _questions = list;
      _currentIndex = 0;
    } catch (e) {
      print("Error loading questions: $e");
      _questions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================
  // إرسال إجابة سؤال
  // ==========================
  Future<void> submitAnswer({
    required int bookId,
    required int answerId,
  }) async {
    if (currentQuestion == null) return;

    _isSubmitting = true;
    notifyListeners();

    try {
      await _quizRepo.submitAnswer(
        bookId: bookId,
        questionId: currentQuestion!.id,
        answerId: answerId,
      );

      // الانتقال للسؤال التالي
      if (_currentIndex < _questions.length - 1) {
        _currentIndex++;
      } else {
        // وصل للنهاية → إنهاء الجلسة تلقائيًا
        await finishSession(bookId);
      }
    } catch (e) {
      print("Error submitting answer: $e");
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ==========================
  // إنهاء الجلسة
  // ==========================
  Future<void> finishSession(int bookId) async {
    try {
      final result = await _quizRepo.finishSession(bookId);

      _totalPoints = result["total_points"] ?? 0;
      _isSessionFinished = true;

    } catch (e) {
      print("Error finishing quiz session: $e");
    } finally {
      notifyListeners();
    }
  }

  // ==========================
  // إعادة تعيين الحالة
  // ==========================
  void reset() {
    _questions = [];
    _currentIndex = 0;
    _isSubmitting = false;
    _isLoading = false;
    _isSessionFinished = false;
    _totalPoints = 0;

    notifyListeners();
  }
}
