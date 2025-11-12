import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// صفحات التطبيق
import 'features/auth/presentation/pages/home_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/welcome_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/auth/presentation/pages/choose_interests_page.dart';
import 'features/auth/presentation/pages/success_page.dart';
import 'features/quotes/presentation/pages/quote.dart';

// Provider و Repository
import 'features/profile/provider/profile_provider.dart';
import 'features/profile/repository/profile_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final profileRepo = ProfileRepository();

    return MultiProvider(
      providers: [
        /// 🔹 إعداد ProfileProvider مرة واحدة
        /// وضعنا mockMode = true فقط للتجربة داخل صفحة البروفايل
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            repository: profileRepo,
            mockMode: true, // ✅ يجعل الصفحة وهمية دون التأثير على باقي الصفحات
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Readify',
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomePage(),
          
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/profile': (context) => const ProfilePage(),
          '/choose-interests': (context) => const ChooseInterestsPage(),
          '/success': (context) => const SuccessPage(),
          '/home': (context) => const HomePage(),
          '/quote': (context) => QuotesPage(),
        },
      ),
    );
  }
}
