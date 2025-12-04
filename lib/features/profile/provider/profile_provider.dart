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

  /// قائمة الكتب المحملة محليًا أو من الباك
  List<BookModel> downloadedBooks = [];

  /// تحميل بيانات المستخدم من الباك اند
  Future<void> loadUser() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final token = await PrefsHelper.getToken();
      if (token != null && token.isNotEmpty) {
        _repository.setAuthToken(token.trim());
      }

      // جلب بيانات المستخدم
      user = await _repository.getCurrentUser();

      // جلب النقاط الكلية للمستخدم من الباك
      try {
        final totalPoints = await _repository.getUserTotalPoints(); // يجب أن يُرجع int
        user = user!.copyWith(points: totalPoints);
      } catch (e) {
        print("Error fetching total points: $e");
      }

    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }


  /// تحديث بيانات المستخدم عبر الباك اند
  Future<bool> updateUser(Map<String, dynamic> body) async {
    if (user == null) return false;

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
      return true;
    } catch (e) {
      loading = false;
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// إضافة كتاب محمّل إلى قائمة downloadedBooks
  void addDownloadedBook(BookModel book) {
    if (!downloadedBooks.any((b) => b.id == book.id)) {
      downloadedBooks.add(book);
      notifyListeners();
    }
  }

  /// 🔹 جلب الكتب المحمّلة للمستخدم من الباك
  Future<void> loadDownloadedBooks() async {
    if (user == null) return;

    try {
      loading = true;
      error = null;
      notifyListeners();

      downloadedBooks = await _repository.getUserBooks(); // يجب أن تعيد List<BookModel>

      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      error = e.toString();
      notifyListeners();
    }
  }

  /// تسجيل الخروج
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

      // الانتقال إلى صفحة اختيار الحساب
      await Future.delayed(const Duration(milliseconds: 400));
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/auth_choice',
            (route) => false,
      );
    } catch (e) {
      loading = false;
      error = e.toString();
      notifyListeners();
    }
  }
}

