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
  bool showEditSection = false; // ✅ لإظهار أو إخفاء واجهة التعديل

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
                    setState(() {
                      showEditSection = !showEditSection; // ✅ فتح/إغلاق واجهة التعديل
                    });
                  },
                  actions: [
                    {'icon': 'assets/icons/star_filled.png', 'onTap': () {}},
                    {
                      'icon': 'assets/icons/edit.png',
                      'onTap': () {
                        setState(() {
                          showEditSection = !showEditSection;
                        });
                      }
                    },
                    {'icon': 'assets/icons/book_open.png', 'onTap': () {}},
                    {'icon': 'assets/icons/book.png', 'onTap': () {}},
                    {'icon': 'assets/icons/gift.png', 'onTap': () {}},
                    {
                      'icon': 'assets/icons/logout.png',
                      'onTap': () {
                        provider.logout(context);
                      }
                    },
                  ],
                ),

                const SizedBox(height: 20),

                // ✅ واجهة تعديل الملف الشخصي وكلمة المرور
                if (showEditSection)
                  _buildEditSection(context, user)
                else ...[
                  // لوحة عدد النقاط
                  ProfileSection(
                    title: 'عدد النقاط',
                    subtitle: '${user.points}',
                    iconAsset: 'assets/icons/star_filled.png',
                    onTap: () {},
                  ),

                  const SizedBox(height: 16),

                  // أقسام أخرى
                  _buildSectionTile(
                      'الكتب المحملة', 'عرض الكتب التي حملتها', () {}),
                  _buildSectionTile(
                      'الكتب المدفوعة', 'عرض الكتب المدفوعة', () {}),
                  _buildSectionTile(
                      'المكافآت', 'تفاصيل المكافآت والاستبدال', () {}),
                  const SizedBox(height: 30),
                ],
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

  // ✅ قسم تعديل الملف الشخصي وكلمة المرور
  Widget _buildEditSection(BuildContext context, UserModel user) {
    final usernameC = TextEditingController(text: user.username);
    final emailC = TextEditingController(text: user.email);
    final ageC = TextEditingController(text: user.age.toString());
    final oldPassC = TextEditingController();
    final newPassC = TextEditingController();
    int? gender = user.gender;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Card(
        color: Colors.white.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('معلومات الحساب',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 10),

              TextField(
                controller: usernameC,
                decoration: const InputDecoration(labelText: 'اسم المستخدم'),
              ),
              TextField(
                controller: emailC,
                decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                readOnly: true,
              ),
              TextField(
                controller: ageC,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'العمر'),
              ),
              const SizedBox(height: 10),
              DropdownButton<int>(
                value: gender,
                items: const [
                  DropdownMenuItem(child: Text('ذكر'), value: 1),
                  DropdownMenuItem(child: Text('أنثى'), value: 2),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => gender = v);
                },
              ),
              const Divider(height: 30),

              const Text('تغيير كلمة المرور',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 10),

              TextField(
                controller: oldPassC,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'كلمة المرور الحالية'),
              ),
              TextField(
                controller: newPassC,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'كلمة المرور الجديدة'),
              ),
              TextField(
                controller: newPassC,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور الجديدة'),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final body = {
                        'username': usernameC.text,
                        'age': int.tryParse(ageC.text) ?? user.age,
                        'gender': gender
                      };
                      final ok = await provider.updateUser(body);
                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('تم تحديث المعلومات بنجاح'),
                              backgroundColor: Color(0xFFE3EDF2)),
                        );
                        setState(() => showEditSection = false);
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('حفظ'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      setState(() => showEditSection = false);
                    },
                    child: const Text('إلغاء'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
