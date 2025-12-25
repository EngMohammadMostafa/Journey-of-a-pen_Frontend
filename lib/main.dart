import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ApiService
import 'core/api/api_service.dart';

// صفحات التطبيق
import 'features/auth/presentation/pages/auth_choice_page.dart';
import 'features/auth/repository/auth_repository.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/welcome_page.dart';
import 'features/notifications/provider/notification_provider.dart';
import 'features/notifications/repository/notification_repository.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/auth/presentation/pages/choose_interests_page.dart';
import 'features/auth/presentation/pages/success_page.dart';
import 'features/question/provider/quiz_provider.dart';
import 'features/question/repository/quiz_repository.dart';
import 'features/quotes/presentation/pages/quote.dart';
import 'features/competitions/provider/competition_provider.dart';
import 'features/competitions/repository/competition_repository.dart';


// Provider و Repository
import 'features/profile/provider/profile_provider.dart';
import 'features/profile/repository/profile_repository.dart';

// Providers جديدة
import 'features/home/provider/home_provider.dart';
import 'features/books/repository/books_repository.dart';
import 'features/books/data/books_service.dart';

import 'features/home/repository/category_repository.dart';
import 'features/home/data/category_service.dart';
import 'features/request_book/provider/request_book_provider.dart';
import 'features/request_book/repository/request_book_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // إنشاء ApiService واحد فقط لإعادة استخدامه
    final apiService = ApiService();
    final profileRepo = ProfileRepository();

    return MultiProvider(
      providers: [
        // ApiService (مزود مرة واحدة)
        Provider<ApiService>.value(value: apiService),

        // Auth Repository
        Provider<AuthRepository>(
          create: (_) => AuthRepository(apiService),
        ),

        // Profile Provider
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(repository: profileRepo),
        ),

        // Books Repository
        ChangeNotifierProvider<BooksRepository>(
          create: (_) => BooksRepository(apiService),
        ),

        // Categories Repository
        ChangeNotifierProvider<CategoryRepository>(
          create: (_) => CategoryRepository(CategoryService(apiService)),
        ),

        // Home Provider
        ChangeNotifierProvider<HomeProvider>(
          create: (_) => HomeProvider(BooksService(apiService)),
        ),

        ChangeNotifierProvider(
          create: (_) => QuizProvider(QuizRepository(apiService)),
        ),

        // Competition Provider
        ChangeNotifierProvider(
          create: (_) => CompetitionProvider(
            repository: CompetitionRepository(),
          ),
        ),

        // Notification Provider
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(
            NotificationRepository(apiService),
          )..fetchNotifications(),
        ),

        // Request Book Provider
        ChangeNotifierProvider(
          create: (_) => RequestBookProvider(
            repository: RequestBookRepository(apiService),
          ),
        ),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Readify',
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomePage(),
          '/auth_choice': (context) => const AuthChoicePage(),
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
