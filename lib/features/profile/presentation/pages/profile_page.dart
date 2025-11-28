import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_section.dart';
import '../widgets/edit_profile_section.dart';
import '../widgets/purchased_books_section.dart'; // ✅ استدعاء الودجت الجديد

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileProvider provider;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<ProfileProvider>(context, listen: false);
    provider.loadUser(); // جلب بيانات المستخدم من الباك اند
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3EDF2),
      body: Consumer<ProfileProvider>(
        builder: (context, p, _) {
          if (p.loading && p.user == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (p.error != null) {
            return Center(
              child: Text(
                'Error: ${p.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final user = p.user!;

          return SingleChildScrollView(
            child: Column(
              children: [
                // رأس الصفحة
                ProfileHeader(
                  username: user.username,
                  points: user.points,
                  onEditProfile: () {
                    _openEditProfileSheet(context);
                  },
                  actions: [
                    {'icon': 'assets/icons/star_filled.png', 'onTap': () {}},
                    {'icon': 'assets/icons/edit.png', 'onTap': () {
                      _openEditProfileSheet(context);
                    }},
                    {'icon': 'assets/icons/book_open.png', 'onTap': () {}},
                    {'icon': 'assets/icons/book.png', 'onTap': () {
                      _showPurchasedBooks(context);
                    }},
                    {'icon': 'assets/icons/gift.png', 'onTap': () {}},
                    {
                      'icon': 'assets/icons/logout.png',
                      'onTap': () {
                        provider.logout(context);
                      }
                    },
                  ],
                ),

                const SizedBox(height: 30),

                // عدد النقاط
                ProfileSection(
                  title: 'عدد النقاط',
                  subtitle: '${user.points}',
                  iconAsset: 'assets/icons/star_filled.png',
                  onTap: () {},
                ),

                const SizedBox(height: 16),

                // الأقسام الأخرى
                _buildSectionTile('الكتب المحملة', 'عرض الكتب التي حملتها', () {}),
                _buildSectionTile('الكتب المدفوعة', 'عرض الكتب المدفوعة', () {}),
                _buildSectionTile('المكافآت', 'تفاصيل المكافآت والاستبدال', () {}),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 🔹 عنصر واجهة بسيط (القسم)
  Widget _buildSectionTile(String title, String subtitle, VoidCallback onTap) {
    return Card(
      color: Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: onTap,
        title: Text(title, style: const TextStyle(color: Colors.black87)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.black54)),
        trailing: const Icon(Icons.chevron_right, color: Colors.black45),
      ),
    );
  }

  /// 🔹 فتح واجهة التعديل (نصف شاشة من الأسفل)
  _openEditProfileSheet(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    if (provider.user == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditProfileSection(
        user: provider.user, // ✅ تمرير بيانات المستخدم إذا موجودة
      ),
    );
  }



  void _showPurchasedBooks(BuildContext context) {
    final purchasedBooks = [
      {
        'title': 'مدخل إلى البرمجة بلغة Dart',
        'author': 'أحمد علي',
        'cover': 'assets/images/book1.jpg',
        'downloaded': true,
      },
      {
        'title': 'أساسيات Flutter الحديثة',
        'author': 'سارة محمد',
        'cover': 'assets/images/book2.jpg',
        'downloaded': true,
      },
      {
        'title': 'هندسة البرمجيات الشاملة',
        'author': 'خالد إبراهيم',
        'cover': 'assets/images/book3.jpg',
        'downloaded': false,
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PurchasedBooksSection(books: purchasedBooks),
    );
  }
}
