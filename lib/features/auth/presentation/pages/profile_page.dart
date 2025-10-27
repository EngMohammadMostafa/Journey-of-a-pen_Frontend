
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
    provider.loadUser(); // إذا تحتاجين توكن مرريه: provider.loadUser(token: '...')
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F1F1F), // خلفية داكنة كما في الصورة
      body: Consumer<ProfileProvider>(
        builder: (context, p, _) {
          if (p.loading && p.user == null) {
            return Center(child: CircularProgressIndicator());
          }
          if (p.error != null) {
            return Center(child: Text('Error: ${p.error}', style: TextStyle(color: Colors.white)));
          }
          final user = p.user!;
          return SingleChildScrollView(
            child: Column(
              children: [
                ProfileHeader(
                  username: user.username,
                  points: user.points,
                  onEditProfile: () {
                    // افتح صفحة التعديل أو عرض حوار لتعديل الاسم
                    _showEditDialog(context, user);
                  },
                  actions: [
                    {'icon': 'assets/icons/star_filled.png', 'onTap': (){}},
                    {'icon': 'assets/icons/bookmark_filled.png', 'onTap': (){}},
                    {'icon': 'assets/icons/Book.png', 'onTap': (){}},
                    {'icon': 'assets/icons/Gift.png', 'onTap': (){}},
                    {'icon': 'assets/icons/Edit.png', 'onTap': (){}},
                  ],
                ),
                SizedBox(height: 12),
                // لوحة عدد النقاط
                ProfileSection(
                  title: 'number of points',
                  subtitle: '${user.points}',
                  iconAsset: 'assets/icons/star_filled.png',
                  onTap: () {
                    // انتقلي الى صفحة تفاصيل النقاط
                  },
                ),

                // أقسام بروفايل: الاقتباسات المحفوظة، الكتب المحملة، الكتب المدفوعة، المكافئات، الخ
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6),
                  child: Column(
                    children: [
                      _buildSectionTile('الاقتباسات المحفوظة', 'عرض الاقتباسات المحفوظة', () {}),
                      _buildSectionTile('الكتب المحملة', 'عرض الكتب التي حملتها', () {}),
                      _buildSectionTile('الكتب المدفوعة', 'عرض الكتب المدفوعة', () {}),
                      _buildSectionTile('المكافئات', 'تفاصيل المكافئات و الاستبدال', () {}),
                    ],
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTile(String title, String subtitle, VoidCallback onTap) {
    return Card(
      color: Color(0xFFEAF6FB).withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: onTap,
        title: Text(title, style: TextStyle(color: Colors.white)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white60)),
        trailing: Icon(Icons.chevron_right, color: Colors.white60),
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
        title: Text('تحديث الملف'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: usernameC, decoration: InputDecoration(labelText: 'اسم المستخدم')),
            TextField(controller: ageC, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'العمر')),
            DropdownButton<int>(
              value: gender,
              items: [
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
          TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              final body = {'username': usernameC.text, 'age': int.tryParse(ageC.text) ?? user.age, 'gender': gender};
              final ok = await provider.updateUser(body);
              if (ok) Navigator.pop(context);
              // خطأ يعرضه الـ provider
            },
            child: Text('حفظ'),
          )
        ],
      ),
    );
  }
}
