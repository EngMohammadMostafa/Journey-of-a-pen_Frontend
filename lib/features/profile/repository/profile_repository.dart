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

  /// 🔹 جلب محتوى الكتاب حسب الـ bookId
  Future<String> getBookContent(int bookId) async {
    try {
      final response = await _api.get('${ApiEndpoints.userBooks}/$bookId/content');
      if (response.data is String) {
        return response.data as String;
      } else if (response.data is Map<String, dynamic> && response.data['content'] != null) {
        return response.data['content'] as String;
      } else {
        throw Exception("محتوى الكتاب غير متوفر");
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// 🔹 جلب كتب متعددة حسب قائمة IDs
  Future<List<BookModel>> getBooksByIds(List<int> ids) async {
    try {
      final response = await _api.post('${ApiEndpoints.userBooks}/batch', data: {
        'ids': ids,
      });

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

  /// 🔹 جلب النقاط الكلية للمستخدم
  Future<int> getUserTotalPoints() async {
    try {
      final response = await _api.get(ApiEndpoints.userPoints);
      final Map<String, dynamic> data = response.data is String
          ? jsonDecode(response.data)
          : response.data as Map<String, dynamic>;
      return data['total_points'] ?? 0;
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
