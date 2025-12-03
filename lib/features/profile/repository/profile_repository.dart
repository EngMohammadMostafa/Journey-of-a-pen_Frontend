import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';
import '../data/models/user_model.dart';
import '../../books/data/models/book_model.dart';
import '../../../core/constants/api_endpoints.dart';

class ProfileRepository {
  final ApiService _api = ApiService();

  /// جلب بيانات المستخدم الحالي
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _api.get(ApiEndpoints.currentUser);
      final Map<String, dynamic> data = response.data is String
          ? jsonDecode(response.data)
          : response.data as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// تحديث بيانات المستخدم الحالي
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

  /// تسجيل الخروج
  Future<void> logout() async {
    try {
      final response = await _api.post(ApiEndpoints.logout);
      if (response.statusCode != 200) {
        throw Exception('فشل تسجيل الخروج (${response.statusCode})');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// إعداد التوكن
  void setAuthToken(String token) {
    _api.setAuthToken(token);
  }

  /// جلب الكتب التي يمتلكها المستخدم (المحمّلة أو المدفوعة)
  Future<List<BookModel>> getUserBooks() async {
    try {
      final response = await _api.get(ApiEndpoints.userBooks);

      // استخرج قائمة الكتب من المفتاح "books"
      final Map<String, dynamic> data = response.data is String
          ? jsonDecode(response.data)
          : response.data as Map<String, dynamic>;

      final List<dynamic> booksJson = data['books'] ?? [];

      return booksJson
          .map((json) => BookModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }


  String _handleError(DioException e) {
    if (e.response != null) {
      return 'Server error: ${e.response?.statusCode} → ${e.response?.data}';
    } else {
      return 'Connection error: ${e.message}';
    }
  }
}
