import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/prefs_helper.dart';
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

  ///  تحميل بيانات المستخدم من الباك اند
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


  ///  تحديث بيانات المستخدم عبر الباك اند
  Future<bool> updateUser(Map<String, dynamic> body) async {
    if (user == null) return false;

    try {
      loading = true;
      error = null;
      notifyListeners();

      // إنشاء نسخة من المستخدم مع التعديلات
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

      // إرسال التحديث إلى الباك اند
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

  /// تسجيل الخروج
  Future<void> logout(BuildContext context) async {
    try {
      loading = true;
      notifyListeners();

      // تسجيل الخروج من الباك اند
      await _repository.logout();

      // حذف التوكن من التخزين
      await PrefsHelper.clearToken();

      loading = false;
      notifyListeners();

      //  عرض رسالة نجاح
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
