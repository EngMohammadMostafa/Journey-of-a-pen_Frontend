import 'package:flutter/foundation.dart';
import '../../../../core/utils/prefs_helper.dart';
import '../data/models/user_model.dart';
import '../repository/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;
  final bool mockMode; // ✅ إضافة وضع وهمي لتجربة الصفحة بدون API

  ProfileProvider({
    required ProfileRepository repository,
    this.mockMode = false, // افتراضيًا مغلق
  }) : _repository = repository;

  UserModel? user;
  bool loading = false;
  String? error;

  /// 🔹 تحميل بيانات المستخدم
  Future<void> loadUser() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      if (mockMode) {
        // 🧩 بيانات وهمية لتجربة واجهة الملف الشخصي
        await Future.delayed(const Duration(seconds: 1));
        user = UserModel(
          id: 1,
          username: "محمد أحمد",
          email: "mohamed@example.com",
          userType: 1,
          points: 2450,
          purchasesCount: 7,
          age: 23,
          gender: 1,
        );
        loading = false;
        notifyListeners();
        return;
      }

      // في الحالة الحقيقية (API)
      final token = await PrefsHelper.getToken();
      if (token != null) {
        _repository.setAuthToken(token);
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

  /// ✏️ تحديث بيانات المستخدم
  Future<bool> updateUser(Map<String, dynamic> body) async {
    if (user == null) return false;

    try {
      loading = true;
      error = null;
      notifyListeners();

      if (mockMode) {
        // ✅ تحديث محلي فقط (بدون API)
        await Future.delayed(const Duration(milliseconds: 500));
        user = user!.copyWith(
          username: body['username'] ?? user!.username,
          age: body['age'] ?? user!.age,
          gender: body['gender'] ?? user!.gender,
        );
        loading = false;
        notifyListeners();
        return true;
      }

      // 🔸 تحديث فعلي عبر الريبو
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
  /// 🚪 تسجيل الخروج
  Future<void> logout() async {
    try {
      loading = true;
      notifyListeners();

      if (mockMode) {
        // 🧩 في وضع التجربة، فقط نحذف المستخدم محليًا
        await Future.delayed(const Duration(milliseconds: 400));
        user = null;
        await PrefsHelper.clearToken();
        loading = false;
        notifyListeners();
        return;
      }

      // 🔹 في الوضع الحقيقي (مع API)
      final token = await PrefsHelper.getToken();
      if (token != null) {
        _repository.setAuthToken(token);
        await _repository.logout(); // ← نرسل الطلب إلى API
      }

      // حذف بيانات المستخدم محليًا
      user = null;
      await PrefsHelper.clearToken();

      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      error = e.toString();
      notifyListeners();
    }
  }

}
