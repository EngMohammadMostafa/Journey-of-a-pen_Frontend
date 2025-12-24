import 'package:flutter/material.dart';
import '../data/models/competition_model.dart';
import '../data/models/competition_book_model.dart';
import '../repository/competition_repository.dart';

class CompetitionProvider extends ChangeNotifier {
  final CompetitionRepository _repository;

  CompetitionProvider({required CompetitionRepository repository})
      : _repository = repository;

  // ================== State ==================
  bool loading = false;
  String? error;

  List<CompetitionModel> competitions = [];
  List<CompetitionBookModel> competitionBooks = [];

  // ================== Competitions ==================

  /// جلب جميع المسابقات المتاحة
  Future<void> loadCompetitions() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      competitions = await _repository.getCompetitions();

    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ================== Competition Books ==================

  /// جلب كتب مسابقة معينة
  Future<void> loadCompetitionBooks(int competitionId) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      competitionBooks =
      await _repository.getCompetitionBooks(competitionId);

    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ================== Participate ==================

  /// رفع كتاب للمسابقة
  Future<bool> participateInCompetition({
    required int competitionId,
    required String title,
    required String filePath,
  }) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      await _repository.participate(
        competitionId: competitionId,
        title: title,
        filePath: filePath,
      );

      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ================== Like ==================

  /// لايك / إلغاء لايك
  Future<void> toggleLike(int competitionBookId) async {
    try {
      final result = await _repository.toggleLike(competitionBookId);

      final index = competitionBooks.indexWhere(
            (b) => b.id == competitionBookId,
      );

      if (index != -1) {
        competitionBooks[index] =
            competitionBooks[index].copyWith(
              likesCount: result.likesCount,
            );

        //  تعديل بسيط مستحسن: ترتيب حسب الإعجابات
        competitionBooks.sort(
              (a, b) => b.likesCount.compareTo(a.likesCount),
        );
      }

      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  // ================== Helpers ==================

  void clearBooks() {
    competitionBooks.clear();
    notifyListeners();
  }
}
