import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/prefs_helper.dart';
import '../../books/data/models/book_model.dart';
import '../data/models/user_model.dart';
import '../repository/profile_repository.dart';
import 'dart:io';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileProvider({required ProfileRepository repository}) : _repository = repository;

  UserModel? user;
  bool loading = false;
  String? error;

  List<BookModel> downloadedBooks = [];
  int userPoints = 0;

  /// تحميل بيانات المستخدم من الباك اند
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

  /// تحديث بيانات المستخدم
  Future<String?> updateUser(Map<String, dynamic> body) async {
    if (user == null) return "المستخدم غير موجود";

    if ((body['username'] as String?)?.trim().isEmpty ?? true ||
        (body['age'] == null) ||
        (body['gender'] == null)) {
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
      if (kDebugMode) print("Error updating user: $e");
      return "فشل تحديث البيانات، حاول مرة أخرى";
    }
  }

  /// تحميل نقاط المستخدم من الباك
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

  /// 🔹 تحديث النقاط بطريقة آمنة
  void updateUserPoints(int newPoints) {
    userPoints = newPoints;
    if (user != null) {
      user = user!.copyWith(points: newPoints);
    }
    notifyListeners();
  }

  /// إضافة كتاب محليًا
  void addDownloadedBook(BookModel book) {
    if (!downloadedBooks.any((b) => b.id == book.id)) {
      downloadedBooks.add(book);
      PrefsHelper.setDownloadedBookIds(downloadedBooks.map((b) => b.id).toList());
      notifyListeners();
    }
  }

  /// تحميل قائمة الكتب من الباك
  Future<void> loadDownloadedBooks() async {
    if (user == null) return;

    try {
      loading = true;
      error = null;
      notifyListeners();

      downloadedBooks = await _repository.getUserBooks();
      await PrefsHelper.setDownloadedBookIds(downloadedBooks.map((b) => b.id).toList());

      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      error = e.toString();
      notifyListeners();
    }
  }

  /// تنزيل محتوى كتاب وحفظه محليًا
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

  /// فتح الكتاب محليًا
  Future<File?> openBook(int bookId) async {
    return PrefsHelper.getBookFile(bookId);
  }

  /// تحميل الكتب من النسخة المحلية فقط
  Future<void> loadBooksFromLocal() async {
    final bookIds = await PrefsHelper.getDownloadedBookIds();
    downloadedBooks = await _repository.getBooksByIds(bookIds);
    notifyListeners();
  }

  /// تسجيل الخروج
  Future<void> logout(BuildContext context) async {
    try {
      loading = true;
      notifyListeners();

      await _repository.logout();
      await PrefsHelper.clearUserData();

      loading = false;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تسجيل الخروج بنجاح'),
          backgroundColor: Colors.grey,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 400));
      Navigator.of(context).pushNamedAndRemoveUntil('/auth_choice', (route) => false);
    } catch (e) {
      loading = false;
      error = e.toString();
      notifyListeners();
    }
  }
}
