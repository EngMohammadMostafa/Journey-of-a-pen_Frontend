import 'package:flutter/cupertino.dart';

import '../data/models/notification_model.dart';
import '../repository/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;

  NotificationProvider(this._repository);

  // ==========================
  // الحالة
  // ==========================
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  /// 🆕 عدد الإشعارات السابقة (للمقارنة)
  int _lastNotificationsCount = 0;

  // ==========================
  // Getters
  // ==========================
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 🆕 عدد الإشعارات الجديدة (Badge)
  int get unreadCount =>
      _notifications.where((n) => n.isNew).length;

  // ==========================
  // جلب الإشعارات من الباك
  // ==========================
  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await _repository.fetchNotifications();

      /// 🔔 اكتشاف إشعار جديد
      if (list.length > _lastNotificationsCount) {
        debugPrint("🔔 New notification arrived");
        // هنا يمكن لاحقًا إضافة Sound / SnackBar
      }

      _lastNotificationsCount = list.length;

      _notifications = list;

    } catch (e) {
      _notifications = [];
      _errorMessage = "فشل تحميل الإشعارات";
      debugPrint("Error fetching notifications: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================
  // تحديث يدوي
  // ==========================
  Future<void> refresh() async {
    await fetchNotifications();
  }

  // ==========================
  // تعليم إشعار كمقروء
  // ==========================
  void markAsRead(NotificationModel notification) {
    notification.isNew = false;
    notifyListeners();
  }

  // ==========================
  // تعليم الكل كمقروء
  // ==========================
  void markAllAsRead() {
    for (final n in _notifications) {
      n.isNew = false;
    }
    notifyListeners();
  }

  // ==========================
  // عدد الإشعارات
  // ==========================
  int get notificationsCount => _notifications.length;

  // ==========================
  // مسح البيانات محليًا
  // ==========================
  void clear() {
    _notifications = [];
    _errorMessage = null;
    _isLoading = false;
    _lastNotificationsCount = 0;
    notifyListeners();
  }
}
