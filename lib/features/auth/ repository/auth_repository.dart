import 'package:book_worm_haven/core/api/api_service.dart';
import 'package:book_worm_haven/core/constants/api_endpoints.dart';
import 'package:book_worm_haven/features/auth/data/models/login_request.dart';
import 'package:book_worm_haven/features/auth/data/models/login_response.dart';
import 'package:book_worm_haven/features/auth/data/models/register_request.dart';
import 'package:book_worm_haven/features/auth/data/models/register_response.dart';



class AuthRepository {
  Future<bool> register(String name, String email, String password, String age, String gender) async {
    try {
      // هنا يمكن استدعاء الـ API الفعلي
      print("Registering user: Name=$name, Email=$email, Password=$password, Age=$age, Gender=$gender");
      await Future.delayed(const Duration(seconds: 1));
      return true; // افتراض النجاح
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      print("Logging in: Email=$email, Password=$password");
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      return false;
    }
  }
}


