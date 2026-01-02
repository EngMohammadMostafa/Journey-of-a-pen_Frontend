import '../../../../../core/api/api_service.dart';
import 'models/notification_model.dart';

class NotificationService {
  final ApiService _api;

  NotificationService(this._api);

  // جلب جميع الإشعارات
  Future<List<NotificationModel>> fetchNotifications() async {
    final response = await _api.get('/notifications');
    final data = response.data as List<dynamic>;

    return data
        .map((json) => NotificationModel.fromJson(json))
        .toList();
  }
}
