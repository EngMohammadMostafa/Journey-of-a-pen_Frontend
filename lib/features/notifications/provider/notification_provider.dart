import 'package:flutter/material.dart';
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

  // ==========================
  // Getters
  // ==========================
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ==========================
  // جلب الإشعارات من الباك
  // ==========================
  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await _repository.fetchNotifications();

      /// Laravel: Notification::latest()->get()
      /// إذن الترتيب جاهز من الباك
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
  // تحديث يدوي (Pull to refresh)
  // ==========================
  Future<void> refresh() async {
    await fetchNotifications();
  }

  // ==========================
  // عدد الإشعارات
  // ==========================
  int get notificationsCount => _notifications.length;

  // ==========================
  // مسح البيانات محليًا (عند تسجيل الخروج)
  // ==========================
  void clear() {
    _notifications = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
