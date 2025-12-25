import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/notification_model.dart';
import '../../provider/notification_provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  Set<String> readIds = {}; // IDs المقروءة
  final player = AudioPlayer();  // مشغل الصوت لمرة واحدة فقط
  bool _autoRefreshStarted = false;

  @override
  void initState() {
    super.initState();
    _loadReadIds();

    // بدء التحديث التلقائي بعد تحميل الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoRefresh();
    });
  }

  Future<void> _loadReadIds() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      readIds = prefs.getStringList('read_notifications')?.toSet() ?? {};
    });
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (!readIds.contains(notification.notificationId.toString())) {
      readIds.add(notification.notificationId.toString());
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('read_notifications', readIds.toList());

      // تعليم الإشعار كمقروء في البروفايدر
      final provider = context.read<NotificationProvider>();
      provider.markAsRead(notification);

      setState(() {}); // تحديث الواجهة فورًا لإلغاء "جديد"
    }
  }

  bool _isNew(NotificationModel notification) {
    return !readIds.contains(notification.notificationId.toString());
  }

  void _playNotificationSound() async {
    try {
      await player.play(AssetSource('sounds/notification.mp3'));
    } catch (e) {
      debugPrint('حدث خطأ أثناء تشغيل الصوت: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 🔄 بدء التحديث التلقائي
  void _startAutoRefresh() {
    if (_autoRefreshStarted) return;
    _autoRefreshStarted = true;

    final provider = context.read<NotificationProvider>();

    Future.doWhile(() async {
      await provider.fetchNotifications();
      await Future.delayed(const Duration(seconds: 5));
      return true; // استمرار الحلقة
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final List<NotificationModel> notifications =
        notificationProvider.notifications;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1C597B),
              Color(0xFF4C869F),
              Color(0xFF7199AA),
              Color(0xFFE3F2FD),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// ===== Header + Badge =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "الإشعارات",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (notifications.any((n) => _isNew(n)))
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          notifications.where((n) => _isNew(n)).length
                              .toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                /// 🔄 Loading
                if (notificationProvider.isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )

                /// ❌ Error
                else if (notificationProvider.errorMessage != null)
                  Expanded(
                    child: Center(
                      child: Text(
                        notificationProvider.errorMessage!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )

                /// 📭 Empty
                else if (notifications.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text(
                          "لا توجد إشعارات حالياً",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )

                  /// ✅ Data
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          final bool isNew = _isNew(notification);
                          final formattedDate = DateFormat('yyyy/MM/dd')
                              .format(notification.createdAt);

                          return TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 500),
                            tween: Tween(begin: 0, end: 1),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, (1 - value) * 20),
                                  child: child,
                                ),
                              );
                            },
                            child: GestureDetector(
                              onTap: () async {
                                // تعليم الإشعار كمقروء وتحديث الواجهة
                                await _markAsRead(notification);

                                // تشغيل الصوت
                                _playNotificationSound();

                                // عرض رسالة قصيرة
                                _showSnackBar(
                                    "تم قراءة الإشعار: ${notification.title}");

                                // عرض حوار التفاصيل
                                showGeneralDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  barrierLabel: "Dialog",
                                  transitionDuration:
                                  const Duration(milliseconds: 350),
                                  pageBuilder: (_, animation, __) {
                                    return BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 4, sigmaY: 4),
                                      child: Center(
                                        child: Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(20),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(20),
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF1C597B),
                                                  Color(0xFF4C869F),
                                                  Color(0xFF77A9C4),
                                                ],
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.notifications,
                                                  size: 50,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(height: 15),
                                                Text(
                                                  notification.title,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  notification.content,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    height: 1.5,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.white,
                                                      foregroundColor:
                                                      const Color(0xFF1C597B),
                                                      elevation: 3,
                                                      padding:
                                                      const EdgeInsets.symmetric(
                                                          vertical: 12),
                                                      shape:
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(12),
                                                      ),
                                                    ),
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text(
                                                      "حسناً",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: isNew
                                      ? Border.all(
                                    color: Colors.green,
                                    width: 1.5,
                                  )
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 6,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xFF1C597B),
                                    child: Icon(Icons.notifications,
                                        color: Colors.white),
                                  ),
                                  title: Text(
                                    notification.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1C597B),
                                    ),
                                  ),
                                  subtitle: Text(
                                    notification.content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      if (isNew)
                                        Container(
                                          margin:
                                          const EdgeInsets.only(top: 4),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color:
                                            Colors.green.withOpacity(0.15),
                                            borderRadius:
                                            BorderRadius.circular(12),
                                          ),
                                          child: const Text(
                                            "جديد",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
