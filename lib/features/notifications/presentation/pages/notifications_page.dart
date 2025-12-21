import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // بيانات وهمية تمثل الإشعارات
    final notifications = [
      {
        "id": 1,
        "title": "بدأت فترة المسابقة!",
        "description": "يمكنك الآن المشاركة في المسابقة والحصول على جوائز رائعة.",
        "date": DateTime(2025, 11, 27),
        "icon": Icons.emoji_events,
      },
      {
        "id": 2,
        "title": "كتاب جديد متاح",
        "description": "تم إضافة كتاب 'رحلة البطل' إلى مكتبتك الرقمية.",
        "date": DateTime(2025, 11, 25),
        "icon": Icons.book,
      },
      {
        "id": 3,
        "title": "تحديث جديد للتطبيق",
        "description": "تم تحسين واجهة المستخدم وإصلاح بعض الأخطاء.",
        "date": DateTime(2025, 11, 20),
        "icon": Icons.update,
      },
    ];

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
                Expanded(
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      final date = notification['date'] as DateTime?;
                      final formattedDate = date != null
                          ? DateFormat('yyyy/MM/dd').format(date)
                          : '';
                      final title = notification['title'] as String? ?? '';
                      final description =
                          notification['description'] as String? ?? '';
                      final icon = notification['icon'] as IconData? ?? Icons.info;

                      return GestureDetector(
                        onTap: () {
                          // نافذة حوار عند الضغط على الإشعار
                          showGeneralDialog(
                            context: context,
                            barrierDismissible: true,
                            barrierLabel: "Dialog",
                            transitionDuration: const Duration(milliseconds: 350),
                            pageBuilder: (context, animation, secondaryAnimation) {
                              return Stack(
                                children: [
                                  BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                                    child: Container(color: Colors.black.withOpacity(0.2)),
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
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20),
                                              gradient: const LinearGradient(
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
                                                Icon(
                                                  icon,
                                                  size: 50,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(height: 15),
                                                Text(
                                                  title,
                                                  style: const TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  description,
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
                                                      foregroundColor: Color(0xFF1C597B),
                                                      elevation: 3,
                                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                    ),
                                                    onPressed: () => Navigator.pop(context),
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
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF1C597B),
                              child: Icon(icon, color: Colors.white),
                            ),
                            title: Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1C597B),
                              ),
                            ),
                            subtitle: Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              formattedDate,
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
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
