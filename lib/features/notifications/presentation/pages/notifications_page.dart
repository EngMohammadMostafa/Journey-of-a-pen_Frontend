import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/notification_model.dart';
import '../../provider/notification_provider.dart';


class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "الإشعارات",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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

                          final formattedDate = DateFormat('yyyy/MM/dd')
                              .format(notification.createdAt);

                          const icon = Icons.notifications;

                          return GestureDetector(
                            onTap: () {
                              showGeneralDialog(
                                context: context,
                                barrierDismissible: true,
                                barrierLabel: "Dialog",
                                transitionDuration:
                                const Duration(milliseconds: 350),
                                pageBuilder:
                                    (context, animation, secondaryAnimation) {
                                  return Stack(
                                    children: [
                                      BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 4, sigmaY: 4),
                                        child: Container(
                                          color: Colors.black.withOpacity(0.2),
                                        ),
                                      ),
                                      Center(
                                        child: ScaleTransition(
                                          scale: CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.elasticOut,
                                          ),
                                          child: FadeTransition(
                                            opacity: animation,
                                            child: Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(20),
                                              ),
                                              child: Container(
                                                padding:
                                                const EdgeInsets.all(20),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                  BorderRadius.circular(20),
                                                  gradient:
                                                  const LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
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
                                                      icon,
                                                      size: 50,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(height: 15),
                                                    Text(
                                                      notification.title,
                                                      style: const TextStyle(
                                                        fontSize: 22,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign: TextAlign.center,
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
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                          Colors.white,
                                                          foregroundColor:
                                                          const Color(
                                                              0xFF1C597B),
                                                          elevation: 3,
                                                          padding: const EdgeInsets.symmetric(
                                                            vertical: 12,
                                                          ),
                                                          shape:
                                                          RoundedRectangleBorder(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                12),
                                                          ),
                                                        ),
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child: const Text(
                                                          "حسناً",
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                            FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
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
                                  child: Icon(icon, color: Colors.white),
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
                                trailing: Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
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
