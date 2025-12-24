import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';
import '../../../core/constants/api_endpoints.dart';
import '../data/models/notification_model.dart';

class NotificationRepository {
  final ApiService _api = ApiService();

  // ==========================
  // جلب جميع الإشعارات
  // ==========================
  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      final response = await _api.get(ApiEndpoints.notifications);

      /// الباك يرجع List مباشرة
      final dynamic rawData = response.data;

      final List<dynamic> data =
      rawData is String ? jsonDecode(rawData) : rawData as List<dynamic>;

      return data
          .map((json) =>
          NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();

    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ==========================
  // إعداد التوكن (مثل ProfileRepository)
  // ==========================
  void setAuthToken(String token) {
    _api.setAuthToken(token);
  }

  // ==========================
  // معالجة الأخطاء
  // ==========================
  String _handleError(DioException e) {
    if (e.response != null) {
      return 'Server error: ${e.response?.statusCode} → ${e.response?.data}';
    } else {
      return 'Connection error: ${e.message}';
    }
  }
}
