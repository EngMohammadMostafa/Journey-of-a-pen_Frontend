import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/user_model.dart';
import '../../provider/profile_provider.dart';

class EditProfileSection extends StatefulWidget {
  final UserModel? user; //  اختياري

  const EditProfileSection({Key? key, this.user}) : super(key: key);

  @override
  State<EditProfileSection> createState() => _EditProfileSectionState();
}


class _EditProfileSectionState extends State<EditProfileSection> {
  late TextEditingController usernameC;
  late TextEditingController ageC;
  late TextEditingController oldPassC;
  late TextEditingController newPassC;

  int? gender;
  bool showPasswordSection = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    usernameC = TextEditingController();
    ageC = TextEditingController();
    oldPassC = TextEditingController();
    newPassC = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserData());
  }

  Future<void> _loadUserData() async {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    UserModel? user = widget.user ?? provider.user;

    if (user == null) {
      await provider.loadUser();
      user = provider.user;
    }

    if (user != null) {
      usernameC.text = user.username;
      ageC.text = user.age?.toString() ?? '';
      gender = user.gender;
    }

    if (mounted) setState(() => isLoading = false);
  }



  @override
  void dispose() {
    usernameC.dispose();
    ageC.dispose();
    oldPassC.dispose();
    newPassC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context, listen: false);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1C597B),
                Color(0xFF4C869F),
                Color(0xFF7199AA),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const Text(
                    'تحديث الملف الشخصي',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _inputField(
                    controller: usernameC,
                    label: 'اسم المستخدم',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),
                  _inputField(
                    controller: ageC,
                    label: 'العمر',
                    icon: Icons.cake_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: gender,
                    decoration: _inputDecoration(
                      label: 'الجنس',
                      icon: Icons.wc_outlined,
                    ),
                    dropdownColor: const Color(0xFF1C597B),
                    style: const TextStyle(color: Colors.white),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text("ذكر")),
                      DropdownMenuItem(value: 2, child: Text("أنثى")),
                    ],
                    onChanged: (v) => setState(() => gender = v),
                  ),
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: () =>
                        setState(() => showPasswordSection = !showPasswordSection),
                    icon: const Icon(Icons.lock_reset, color: Colors.white),
                    label: Text(
                      showPasswordSection
                          ? "إلغاء تغيير كلمة المرور"
                          : "تغيير كلمة المرور",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: showPasswordSection
                        ? Column(
                      key: const ValueKey('password_section'),
                      children: [
                        _inputField(
                          controller: oldPassC,
                          label: 'كلمة المرور القديمة',
                          icon: Icons.lock_outline,
                          obscureText: true,
                        ),
                        const SizedBox(height: 12),
                        _inputField(
                          controller: newPassC,
                          label: 'كلمة المرور الجديدة',
                          icon: Icons.lock_reset_outlined,
                          obscureText: true,
                        ),
                        _inputField(
                          controller: newPassC,
                          label: 'تأكيد كلمة المرور الجديدة',
                          icon: Icons.lock_reset_outlined,
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                      ],
                    )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1C597B),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final body = {
                          'username': usernameC.text,
                          'age': int.tryParse(ageC.text),
                          'gender': gender,
                          if (showPasswordSection) ...{
                            'old_password': oldPassC.text,
                            'new_password': newPassC.text,
                          },
                        };

                        final ok = await provider.updateUser(body);
                        if (ok && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم تحديث الملف بنجاح'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('حفظ التعديلات'),
                    ),
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label: label, icon: icon),
    );
  }


  InputDecoration _inputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white),
      filled: true,
      fillColor: Colors.white.withOpacity(0.15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white70),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white),
      ),
    );
  }
}
