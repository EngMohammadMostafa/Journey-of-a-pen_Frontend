import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/user_model.dart';
import '../../provider/profile_provider.dart';

class EditProfileSection extends StatefulWidget {
  final UserModel user;
  const EditProfileSection({super.key, required this.user});

  @override
  State<EditProfileSection> createState() => _EditProfileSectionState();
}

class _EditProfileSectionState extends State<EditProfileSection> {
  final _formKey = GlobalKey<FormState>();
  final passwordC = TextEditingController();
  final confirmC = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context, listen: false);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('تعديل الملف الشخصي',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            const SizedBox(height: 10),
            Text('الاسم: ${widget.user.username}'),
            Text('العمر: ${widget.user.age}'),
            const SizedBox(height: 20),

            TextFormField(
              controller: passwordC,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الجديدة',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
              validator: (v) =>
              v!.length < 6 ? 'يجب أن تكون 6 أحرف على الأقل' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: confirmC,
              decoration: const InputDecoration(
                labelText: 'تأكيد كلمة المرور',
                prefixIcon: Icon(Icons.lock_reset_outlined),
              ),
              obscureText: true,
              validator: (v) =>
              v != passwordC.text ? 'كلمات المرور غير متطابقة' : null,
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => isLoading = true);

                  final success = await provider.updateUser({
                    'password': passwordC.text,
                  });

                  setState(() => isLoading = false);

                  if (success) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                        Text('تم تحديث كلمة المرور بنجاح ✅'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('حفظ التغييرات'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
