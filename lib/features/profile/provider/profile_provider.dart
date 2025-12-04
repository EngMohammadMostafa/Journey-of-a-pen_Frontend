import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/prefs_helper.dart';
import '../../books/data/models/book_model.dart';
import '../data/models/user_model.dart';
import '../repository/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileProvider({
    required ProfileRepository repository,
  }) : _repository = repository;

  UserModel? user;
  bool loading = false;
  String? error;

  List<BookModel> downloadedBooks = [];

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

  /// تحديث بيانات المستخدم عبر الباك اند مع رسائل خطأ واضحة
  Future<String?> updateUser(Map<String, dynamic> body) async {
    if (user == null) return "المستخدم غير موجود";

    // التحقق من الحقول المطلوبة قبل الإرسال
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
      return null; // null يعني نجاح العملية
    } catch (e) {
      loading = false;
      error = e.toString();
      notifyListeners();
      // تحويل أي exception إلى رسالة مفهومة
      if (kDebugMode) print("Error updating user: $e");
      return "فشل تحديث البيانات، حاول مرة أخرى";
    }
  }
  int userPoints = 0;

  Future<void> loadUserPoints() async {
    try {
      loading = true;
      notifyListeners();

      userPoints = await _repository.getUserTotalPoints(); // استدعاء API
      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      error = e.toString();
      notifyListeners();
    }
  }


  void addDownloadedBook(BookModel book) {
    if (!downloadedBooks.any((b) => b.id == book.id)) {
      downloadedBooks.add(book);
      notifyListeners();
    }
  }

  Future<void> loadDownloadedBooks() async {
    if (user == null) return;

    try {
      loading = true;
      error = null;
      notifyListeners();

      downloadedBooks = await _repository.getUserBooks();

      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      loading = true;
      notifyListeners();

      await _repository.logout();
      await PrefsHelper.clearToken();

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
