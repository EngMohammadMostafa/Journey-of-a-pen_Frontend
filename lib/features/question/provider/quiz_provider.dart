import 'package:flutter/material.dart';
import '../data/models/question_model.dart';
import '../repository/quiz_repository.dart';

class QuizProvider extends ChangeNotifier {
  final QuizRepository _quizRepo;

  QuizProvider(this._quizRepo) {
    // جلب النقاط الكلية
    fetchTotalPoints();
  }

  List<QuestionModel> _questions = [];
  int _currentIndex = 0;

  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isSessionFinished = false;

  int _totalPoints = 0;
  String? _errorMessage;

  final Map<int, int> _answers = {}; // questionId -> answerId
  bool _sessionStarted = false;

  ///عدد الأسئلة التي تمت الإجابة عليها (محلي فقط – لا علاقة له بالباك)
  int answeredCount = 0;

  /// حفظ حالة الإجابة (صحيحة/خاطئة) لكل سؤال
  final Map<int, bool> answerCorrectness = {};

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
    notifyListeners();
  }

  /// عدد الإجابات الصحيحة في الجلسة الحالية فقط
  int get correctAnswersInSession =>
      answerCorrectness.values.where((isCorrect) => isCorrect).length;

  /// جلب النقاط الكلية الحالية من الباك
  Future<void> fetchTotalPoints() async {
    try {
      final points = await _quizRepo.fetchUserTotalPoints();
      _totalPoints = points;
      notifyListeners();
    } catch (e) {
      print("Error fetching total points: $e");
      _totalPoints = 0; // إذا فشل الطلب، نترك صفر
    }
  }

  /// تحميل الأسئلة وبدء الجلسة
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
      answerCorrectness.clear();

      score = 0;
      answeredCount = 0;

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

  /// حفظ الإجابة محلياً + إرسالها للباك
  Future<void> saveAnswer({
    required int bookId,
    required int questionId,
    required int answerId,
    required bool isCorrect,
  }) async {
    _answers[questionId] = answerId;

    /// تسجيل هل الإجابة صحيحة أم خاطئة لهذا السؤال
    answerCorrectness[questionId] = isCorrect;

    /// زيادة عدد الإجابات الصحيحة للجلسة
    if (isCorrect) addPoint();

    /// زيادة عدد الأسئلة المجابة
    answeredCount++;

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

  /// إنهاء الجلسة وإرسال الإجابات للباك
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

  /// الخروج من الجلسة دون إرسال النتائج
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

    _answers.clear();
    answerCorrectness.clear();

    answeredCount = 0;
    score = 0;

    _errorMessage = null;
    _sessionStarted = false;

    notifyListeners();
  }
}
