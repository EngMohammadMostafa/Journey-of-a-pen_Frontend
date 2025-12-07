import 'package:flutter/material.dart';
import 'package:book_worm_haven/features/auth/presentation/pages/login_page.dart';
import 'auth_choice_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AuthChoicePage()),
          );
        },
        child: Center(
          child: Container(
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
            child: Stack(
              children: [
                //  الورقة
                Positioned(
                  top: 40,
                  right: 5,
                  bottom: 80,
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent, // يخفي الجزء العلوي
                          Colors.white, // يظهر الباقي
                        ],
                        stops: [0.0, 0.3],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Image.asset(
                      'assets/images/leaf.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const Positioned(
                  top: 120,
                  left: 40,
                  child: Text(
                    "JOURNEY \nOF\n A PEN",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontFamily: 'Cursive',
                      fontStyle: FontStyle.italic,
                      height: 1.2,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                //  صورة الفتاة
                Positioned(
                  bottom: 30,
                  left: 40,
                  right: 40,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(150), //  تدوير
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(
                        'assets/images/girl_reading.png',
                        fit: BoxFit.contain,
                      ),
                    ),
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
