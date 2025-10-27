import 'package:flutter/material.dart';
import '../widgets/auth_button.dart';
import 'login_page.dart';
import 'register_page.dart';

class AuthChoicePage extends StatelessWidget {
  static const routeName = '/auth-choice';

  const AuthChoicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const  BoxDecoration(
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
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // الصورة التوضيحية
                  Container(
                    width: 180,
                    height: 180,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/boy_reading.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // النص الرئيسي
                  const Text(
                    "let's get started",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'RoundedFont',
                    ),
                  ),
                  const SizedBox(height: 48),

                  // زر تسجيل الدخول
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: AuthButton(
                      text: 'login',
                      onPressed: () {
                        Navigator.of(context).pushNamed(LoginPage.routeName);
                      },
                      color: Colors.white,
                      textColor: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // زر إنشاء حساب
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: AuthButton(
                      text: 'sign up',
                      onPressed: () {
                        Navigator.of(context).pushNamed(RegisterPage.routeName);
                      },
                      color: Colors.black,
                      textColor: Colors.white,
                      isSecondary: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
