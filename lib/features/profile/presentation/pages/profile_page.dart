import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/user_model.dart';
import '../../provider/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_section.dart';

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
    provider.loadUser();
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
                child: Text('Error: ${p.error}',
                    style: const TextStyle(color: Colors.red)));
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
                    _showEditDialog(context, user);
                  },
                  actions: [
                    {'icon': 'assets/icons/star_filled.png', 'onTap': () {}},
                    {'icon': 'assets/icons/book_open.png', 'onTap': () {}},
                    {'icon': 'assets/icons/book.png', 'onTap': () {}},
                    {'icon': 'assets/icons/gift.png', 'onTap': () {}},
                    {'icon': 'assets/icons/logout.png', 'onTap': () {
                      provider.logout(context);
                      }
                    },
                  ],
                ),

                const SizedBox(height: 30),

                // لوحة عدد النقاط
                ProfileSection(
                  title: 'عدد النقاط',
                  subtitle: '${user.points}',
                  iconAsset: 'assets/icons/star_filled.png',
                  onTap: () {},
                ),

                const SizedBox(height: 16),

                // أقسام أخرى
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

  void _showEditDialog(BuildContext context, UserModel user) {
    final usernameC = TextEditingController(text: user.username);
    final ageC = TextEditingController(text: user.age.toString());
    int? gender = user.gender;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تحديث الملف'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: usernameC,
                decoration: const InputDecoration(labelText: 'اسم المستخدم')),
            TextField(
                controller: ageC,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'العمر')),
            DropdownButton<int>(
              value: gender,
              items: const [
                DropdownMenuItem(child: Text('ذكر'), value: 1),
                DropdownMenuItem(child: Text('أنثى'), value: 2),
              ],
              onChanged: (v) {
                if (v != null) setState(() => gender = v);
              },
            )
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              final body = {
                'username': usernameC.text,
                'age': int.tryParse(ageC.text) ?? user.age,
                'gender': gender
              };
              final ok = await provider.updateUser(body);
              if (ok) Navigator.pop(context);
            },
            child: const Text('حفظ'),
          )
        ],
      ),
    );
  }
}
