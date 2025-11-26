import 'package:flutter/material.dart';
import '../../../../core/api/api_service.dart';
import '../../repository/auth_repository.dart';
import '../../../../core/utils/validators.dart';

class RegisterPage extends StatefulWidget {
  static const routeName = '/register';
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final ageController = TextEditingController();
  String? selectedGender;

  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    ageController.dispose();
    super.dispose();
  }

  void register() async {
    if (!_formKey.currentState!.validate()) return;

    final int? age = int.tryParse(ageController.text.trim());
    if (age == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Age must be a number")),
      );
      return;
    }

    if (selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select gender")),
      );
      return;
    }

    setState(() => isLoading = true);

    // ✅ تمرير نسخة ApiService
    final errorMessage = await AuthRepository(ApiService()).register(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
      confirmPasswordController.text.trim(),
      age,
      selectedGender!,
    );

    setState(() => isLoading = false);

    if (errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registered successfully!")),
      );
      Navigator.pushNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    const Color buttonColor = Color(0xFF1C597B);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF000000),
                  Color(0xFF7199AA),
                  Color(0xFF4C869F),
                  Color(0xFF1C597B),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: BottomShapesPainter(),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Icon(Icons.edit_note_rounded, color: Colors.white, size: 60),
                  const SizedBox(height: 10),
                  const Text(
                    "Create Account",
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Join our community of readers & writers",
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          // الاسم
                          TextFormField(
                            controller: nameController,
                            decoration: inputStyle(hint: 'Full Name', icon: Icons.person_outline),
                            style: const TextStyle(color: Colors.white),
                            validator: (v) => v!.isEmpty ? "Please enter your name" : null,
                          ),
                          const SizedBox(height: 12),
                          // البريد الإلكتروني
                          TextFormField(
                            controller: emailController,
                            decoration: inputStyle(hint: 'Email', icon: Icons.email_outlined),
                            style: const TextStyle(color: Colors.white),
                            validator: Validators.validateEmail,
                          ),
                          const SizedBox(height: 12),
                          // كلمة المرور
                          TextFormField(
                            controller: passwordController,
                            obscureText: !isPasswordVisible,
                            decoration: inputStyle(
                              hint: 'Password',
                              icon: Icons.lock_outline,
                              suffix: IconButton(
                                icon: Icon(
                                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.white,
                                ),
                                onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            validator: Validators.validatePassword,
                          ),
                          const SizedBox(height: 12),
                          // تأكيد كلمة المرور
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: !isConfirmPasswordVisible,
                            decoration: inputStyle(
                              hint: 'Confirm Password',
                              icon: Icons.lock_reset_outlined,
                              suffix: IconButton(
                                icon: Icon(
                                  isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.white,
                                ),
                                onPressed: () => setState(() => isConfirmPasswordVisible = !isConfirmPasswordVisible),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            validator: (v) {
                              if (v == null || v.isEmpty) return "Please confirm your password";
                              if (v != passwordController.text) return "Passwords do not match";
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          // العمر
                          TextFormField(
                            controller: ageController,
                            decoration: inputStyle(hint: 'Age', icon: Icons.cake_outlined),
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? "Please enter your age" : null,
                          ),
                          const SizedBox(height: 12),
                          // الجنس
                          DropdownButtonFormField<String>(
                            dropdownColor: const Color(0xFF1C597B),
                            style: const TextStyle(color: Colors.white),
                            decoration: inputStyle(hint: 'Gender', icon: Icons.wc_outlined),
                            value: selectedGender,
                            items: const [
                              DropdownMenuItem(value: "male", child: Text("Male")),
                              DropdownMenuItem(value: "female", child: Text("Female")),
                            ],
                            onChanged: (value) => setState(() => selectedGender = value),
                            validator: (value) => value == null ? "Please select gender" : null,
                          ),
                          const SizedBox(height: 25),
                          // الزر
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                textStyle: const TextStyle(fontSize: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 3,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                              )
                                  : const Text('Sign up'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/login'),
                            child: const Text(
                              "Already have an account? Login",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration inputStyle({required String hint, required IconData icon, Widget? suffix}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.2),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.6)),
      ),
    );
  }
}

// رسومات الجبال كما هي
class BottomShapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFF1C597B).withOpacity(0.9)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.8);
    path1.quadraticBezierTo(size.width * 0.3, size.height * 0.7, size.width * 0.6, size.height * 0.85);
    path1.quadraticBezierTo(size.width * 0.85, size.height * 0.95, size.width, size.height * 0.8);
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint1);

    final paint2 = Paint()
      ..color = const Color(0xFF4C869F).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.85);
    path2.quadraticBezierTo(size.width * 0.4, size.height * 0.9, size.width * 0.7, size.height * 0.8);
    path2.quadraticBezierTo(size.width * 0.9, size.height * 0.75, size.width, size.height * 0.9);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);

    final paint3 = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    final path3 = Path();
    path3.moveTo(0, size.height * 0.9);
    path3.quadraticBezierTo(size.width * 0.5, size.height * 0.97, size.width, size.height * 0.9);
    path3.lineTo(size.width, size.height);
    path3.lineTo(0, size.height);
    path3.close();
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
