import 'package:flutter/foundation.dart';
import '../../../../core/utils/prefs_helper.dart';
import '../data/models/user_model.dart';
import '../repository/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileProvider({required ProfileRepository repository}) : _repository = repository;

  UserModel? user;
  bool loading = false;
  String? error;

  /// 🔹 تحميل بيانات المستخدم
  Future<void> loadUser() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      // جلب التوكن من SharedPreferences إن وجد
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

  /// ✏️ تحديث بيانات المستخدم عبر UserModel
  Future<bool> updateUser(Map<String, dynamic> body) async {
    if (user == null) return false;

    try {
      loading = true;
      error = null;
      notifyListeners();

      // تحديث بيانات المستخدم الحالي
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
}
