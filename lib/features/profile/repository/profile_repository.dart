import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';
import '../data/models/user_model.dart';
import '../../../core/constants/api_endpoints.dart';

class ProfileRepository {
  final ApiService _api = ApiService(isMockMode: true);

  /// 🟩 جلب بيانات المستخدم الحالي
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _api.get(ApiEndpoints.currentUser);

      // إذا كان response.data نصي JSON، حوّله إلى Map
      final Map<String, dynamic> data = response.data is String
          ? jsonDecode(response.data)
          : response.data as Map<String, dynamic>;

      return UserModel.fromJson(data);
    } on DioException catch (e) {
      // 🔸 في حال فشل الاتصال أو التوكن غير صالح
      throw Exception(_handleError(e));
    }
  }

  /// ✏️ تحديث بيانات المستخدم الحالي
  Future<UserModel> updateProfile(UserModel user) async {
    try {
      final response = await _api.put(
        ApiEndpoints.currentUser,
        data: user.toJson(),
      );

      final Map<String, dynamic> data = response.data is String
          ? jsonDecode(response.data)
          : response.data as Map<String, dynamic>;

      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// 🚪 تسجيل الخروج
  Future<void> logout() async {
    try {
      final response = await _api.post(ApiEndpoints.logout);

      // تحقق أن الخروج تم بنجاح من السيرفر
      if (response.statusCode != 200) {
        throw Exception('فشل تسجيل الخروج (${response.statusCode})');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// 🔒 إعداد التوكن (في حال كان عندك نظام تسجيل دخول)
  void setAuthToken(String token) {
    _api.setAuthToken(token);
  }

  /// 🧩 دالة لتفسير الأخطاء من Dio
  String _handleError(DioException e) {
    if (e.response != null) {
      return 'Server error: ${e.response?.statusCode} → ${e.response?.data}';
    } else {
      return 'Connection error: ${e.message}';
    }
  }
}
