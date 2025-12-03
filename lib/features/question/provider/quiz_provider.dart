import 'package:flutter/material.dart';
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
  String? _errorMessage;

  final Map<int, int> _answers = {}; // questionId -> answerId
  bool _sessionStarted = false;

  List<QuestionModel> get questions => _questions;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get isSessionFinished => _isSessionFinished;
  int get totalPoints => _totalPoints;
  Map<int, int> get answers => _answers;
  String? get errorMessage => _errorMessage;

  QuestionModel? get currentQuestion =>
      _questions.isNotEmpty ? _questions[_currentIndex] : null;

  int score = 0;

  void addPoint() {
    score += 1;
    _totalPoints = score;
    notifyListeners();
  }

  /// تحميل الأسئلة وبدء الجلسة تلقائياً
  Future<void> loadQuestions(int bookId) async {
    _isLoading = true;
    _isSessionFinished = false;
    _errorMessage = null;
    notifyListeners();

    try {
      if (!_sessionStarted) {
        await _quizRepo.startSession(bookId);
        _sessionStarted = true;
      }

      final list = await _quizRepo.fetchQuestions(bookId);
      _questions = list;
      _currentIndex = 0;
      _answers.clear();
      score = 0;
    } catch (e) {
      _questions = [];
      _errorMessage = e.toString().contains('403')
          ? "لقد أكملت هذه الأسئلة سابقًا ولا يمكنك تكرارها"
          : "حدث خطأ أثناء تحميل الأسئلة";
      print("Error loading questions: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// حفظ الإجابة محلياً وارسالها للباك
  Future<void> saveAnswer({
    required int bookId,
    required int questionId,
    required int answerId,
    required bool isCorrect,
  }) async {
    _answers[questionId] = answerId;
    if (isCorrect) addPoint();

    if (_sessionStarted) {
      try {
        await _quizRepo.recordAnswer(
          bookId: bookId,
          questionId: questionId,
          answerId: answerId,
        );
      } catch (e) {
        print("Error recording answer: $e");
      }
    }

    notifyListeners();
  }

  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  /// إنهاء الجلسة وإرسال النتائج للباك
  Future<void> finishSession(int bookId) async {
    if (_answers.isEmpty) return;

    _isSubmitting = true;
    notifyListeners();

    try {
      final data = _answers.entries
          .map((e) => {"question_id": e.key, "answer_id": e.value})
          .toList();

      final result = await _quizRepo.finishSession(bookId, answers: data);

      _totalPoints = result["total_points"] ?? _totalPoints;
      _isSessionFinished = true;
    } catch (e) {
      print("Error finishing quiz session: $e");
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// إنهاء الجلسة عند الخروج بدون حفظ النتائج
  Future<void> exitSession(int bookId) async {
    if (_sessionStarted) {
      try {
        await _quizRepo.exitSession(bookId);
        _sessionStarted = false;
      } catch (e) {
        print("Error exiting session: $e");
      }
    }
  }

  void reset() {
    _questions = [];
    _currentIndex = 0;
    _isSubmitting = false;
    _isLoading = false;
    _isSessionFinished = false;
    _totalPoints = 0;
    _answers.clear();
    score = 0;
    _errorMessage = null;
    _sessionStarted = false;
    notifyListeners();
  }
}
