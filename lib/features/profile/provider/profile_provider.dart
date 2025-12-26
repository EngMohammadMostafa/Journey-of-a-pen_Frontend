import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/prefs_helper.dart';
import '../../books/data/models/book_model.dart';
import '../data/models/user_model.dart';
import '../repository/profile_repository.dart';
import 'dart:io';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileProvider({required ProfileRepository repository})
      : _repository = repository;

  UserModel? user;
  bool loading = false;
  String? error;

  /// الكتب المحملة
  List<BookModel> downloadedBooks = [];

  /// الكتب المدفوعة
  List<BookModel> purchasedBooks = [];

  int userPoints = 0;

  // =============================
  // تحميل بيانات المستخدم
  // =============================
  Future<void> loadUser() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      final token = await PrefsHelper.getToken();
      if (token != null && token.isNotEmpty) {
        _repository.setAuthToken(token.trim());
      }

      user = await _repository.getCurrentUser();
      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      error = e.toString();
      notifyListeners();
    }
  }

  // =============================
  // تحديث بيانات المستخدم
  // =============================
  Future<String?> updateUser(Map<String, dynamic> body) async {
    if (user == null) return "المستخدم غير موجود";

    if ((body['username'] as String?)?.trim().isEmpty ?? true ||
        body['age'] == null ||
        body['gender'] == null) {
      return "يرجى ملء جميع الحقول المطلوبة";
    }

    try {
      loading = true;
      error = null;
      notifyListeners();

      final updatedUser = UserModel(
        id: user!.id,
        username: body['username'] ?? user!.username,
        email: user!.email,
        userType: user!.userType,
        points: user!.points,
        purchasesCount: user!.purchasesCount,
        age: body['age'] ?? user!.age,
        gender: body['gender'] ?? user!.gender,
      );

      user = await _repository.updateProfile(updatedUser);
      loading = false;
      notifyListeners();
      return null;
    } catch (e) {
      loading = false;
      error = e.toString();
      notifyListeners();
      return "فشل تحديث البيانات";
    }
  }

  // =============================
  // تحميل النقاط من الباك
  // =============================
  Future<void> loadUserPoints() async {
    try {
      loading = true;
      notifyListeners();

      userPoints = await _repository.getUserTotalPoints();

      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      error = e.toString();
      notifyListeners();
    }
  }

  // =============================
  // تحديث النقاط (مستخدم في quiz_page)
  // =============================
  void updateUserPoints(int newPoints) {
    userPoints = newPoints;
    if (user != null) {
      user = user!.copyWith(points: newPoints);
    }
    notifyListeners();
  }

  // =============================
  // إضافة كتاب محمّل (مستخدم في BookReaderPage)
  // =============================
  void addDownloadedBook(BookModel book) {
    if (!downloadedBooks.any((b) => b.id == book.id)) {
      book.isDownloaded = true;
      downloadedBooks.add(book);
    }

    if (book.isPaid && book.isOwned) {
      if (!purchasedBooks.any((b) => b.id == book.id)) {
        purchasedBooks.add(book);
      }
    }

    PrefsHelper.setDownloadedBookIds(
      downloadedBooks.map((b) => b.id).toList(),
    );

    PrefsHelper.setPurchasedBookIds(
      purchasedBooks.map((b) => b.id).toList(),
    );

    notifyListeners();
  }

  // =============================
  // تحميل الكتب من الباك (مرة واحدة)
  // =============================
  Future<void> loadDownloadedBooks() async {
    if (user == null) return;

    try {
      loading = true;
      error = null;
      notifyListeners();

      final allBooks = await _repository.getUserBooks();

      downloadedBooks = allBooks.where((b) => b.isDownloaded).toList();
      purchasedBooks = allBooks.where((b) => b.isPaid && b.isOwned).toList();

      await PrefsHelper.setDownloadedBookIds(
        downloadedBooks.map((b) => b.id).toList(),
      );

      await PrefsHelper.setPurchasedBookIds(
        purchasedBooks.map((b) => b.id).toList(),
      );

      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      error = e.toString();
      notifyListeners();
    }
  }

  // =============================
  // تنزيل كتاب
  // =============================
  Future<void> downloadBook(BookModel book) async {
    try {
      loading = true;
      notifyListeners();

      final bytes = await _repository.getBookContent(book.id);
      await PrefsHelper.saveBookContent(book.id, bytes as List<int>);

      addDownloadedBook(book);

      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      error = e.toString();
      notifyListeners();
    }
  }

  // =============================
  // فتح كتاب محلي
  // =============================
  Future<File?> openBook(int bookId) async {
    return PrefsHelper.getBookFile(bookId);
  }

  // =============================
  // تسجيل الخروج
  // =============================
  Future<void> logout(BuildContext context) async {
    try {
      loading = true;
      notifyListeners();

      await _repository.logout();
      await PrefsHelper.clearUserData();

      loading = false;
      notifyListeners();

      Navigator.of(context)
          .pushNamedAndRemoveUntil('/auth_choice', (route) => false);
    } catch (e) {
      loading = false;
      error = e.toString();
      notifyListeners();
    }
  }
}
