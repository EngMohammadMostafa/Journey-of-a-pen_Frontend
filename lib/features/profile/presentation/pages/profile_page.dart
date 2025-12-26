import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../books/presentation/pages/book_reader_page.dart';
import '../../../request_book/presentation/pages/my_requests_page.dart';
import '../../../request_book/presentation/pages/request_book_form_page.dart';
import '../../provider/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_section.dart';
import '../widgets/edit_profile_section.dart';
import '../widgets/purchased_books_section.dart';

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
    provider.loadUser();              // جلب بيانات المستخدم
    provider.loadDownloadedBooks();   // جلب الكتب المحملة
    provider.loadUserPoints();        // جلب نقاط المستخدم
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

          final user = p.user;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // رأس الصفحة
                ProfileHeader(
                  username: user.username,
                  points: p.userPoints,
                  onEditProfile: () => _openEditProfileSheet(context),
                  actions: [
                    {'icon': 'assets/icons/star_filled.png', 'onTap': () => showPointsPopup(context, p.userPoints)},
                    {'icon': 'assets/icons/edit.png', 'onTap': () => _openEditProfileSheet(context)},
                    {'icon': 'assets/icons/writing_a_book.png', 'onTap': () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RequestBookFormPage()),
                      );
                    }},

                    {'icon': 'assets/icons/book_open.png', 'onTap': () => _showDownloadedBooks(context)},
                    {'icon': 'assets/icons/book.png', 'onTap': () => _showPurchasedBooks(context)},
                    {'icon': 'assets/icons/logout.png', 'onTap': () => provider.logout(context)},
                  ],
                ),

                const SizedBox(height: 30),

                // عدد النقاط
                ProfileSection(
                  title: 'عدد النقاط',
                  subtitle: '${p.userPoints}',
                  iconAsset: 'assets/icons/star_filled.png',
                  onTap: () => showPointsPopup(context, p.userPoints),
                ),



                const SizedBox(height: 16),

                // الأقسام الأخرى
                _buildSectionTile('الكتب المحملة', 'عرض الكتب التي حملتها', () => _showDownloadedBooks(context)),
                _buildSectionTile('الكتب المدفوعة', 'عرض الكتب المدفوعة', () => _showPurchasedBooks(context)),
                _buildSectionTile('طلباتي', 'عرض طلبات النشر', () { Navigator.push(context, MaterialPageRoute(builder: (_) => const MyRequestsPage()),);},),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  ///  عنصر واجهة بسيط (القسم)
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

  ///  فتح واجهة التعديل
  void _openEditProfileSheet(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    if (provider.user == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditProfileSection(user: provider.user),
    );
  }

  void _showDownloadedBooks(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    final downloaded = provider.downloadedBooks;

    if (downloaded.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لا توجد كتب محملة")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PurchasedBooksSection(
        books: downloaded,
        onBookTap: (book) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookReaderPage(book: book),
            ),
          );
        },
      ),
    );
  }

  void _showPurchasedBooks(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    final purchasedBooks = provider.purchasedBooks;

    if (purchasedBooks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لا توجد كتب مدفوعة")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PurchasedBooksSection(
        books: purchasedBooks,
      ),
    );
  }


  ///  نافذة عرض النقاط
  void showPointsPopup(BuildContext context, int points) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1C597B), Color(0xFF4C869F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, size: 60, color: Colors.yellow),
              const SizedBox(height: 15),
              Text('مجموع النقاط', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 20)),
              const SizedBox(height: 10),
              Text('$points ⭐', style: const TextStyle(color: Colors.yellow, fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text(
                points >= 50
                    ? '🎉 لقد وصلت للحد المطلوب! سيتم التواصل معك من قبل المسؤول للحصول على مكافأة'
                    : 'عند وصولك إلى 50 نقطة سيتم التواصل معك للحصول على مكافأة 🎁',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text('حسناً'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
