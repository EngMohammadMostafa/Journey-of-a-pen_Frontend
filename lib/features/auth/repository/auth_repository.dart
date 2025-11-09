import 'dart:convert';
import 'package:book_worm_haven/core/api/api_service.dart';
import 'package:book_worm_haven/core/constants/api_endpoints.dart';
import 'package:book_worm_haven/features/auth/data/models/login_response.dart';
import 'package:book_worm_haven/features/auth/data/models/register_response.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  // ==============================
  // 🔹 تسجيل المستخدم الجديد
  // ==============================
  Future<String?> register(
      String username,
      String email,
      String password,
      String passwordConfirmation,
      int age,
      String gender,
      ) async {
    try {
      final Map<String, dynamic> body = {
        'username': username,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'age': age,
        'gender': gender.toLowerCase(),
      };

      final Response response = await _apiService.post(
        ApiEndpoints.register,
        data: body,
      );

      final status = response.statusCode ?? 0;

      if (status == 200 || status == 201) {
        final dynamic raw = response.data;
        final Map<String, dynamic> data =
        (raw is String) ? jsonDecode(raw) as Map<String, dynamic> : Map<String, dynamic>.from(raw);

        try {
          final registerResponse = RegisterResponse.fromJson(data);
          print('✅ Register Success → Token: ${registerResponse.token}');
          print('👤 User: ${registerResponse.user.username}');
        } catch (_) {
          print('✅ Register Success: ${data['message'] ?? 'Registered (no message field)'}');
        }

        return null; // null تعني لا يوجد خطأ → التسجيل ناجح
      } else {
        print('❌ Register Failed → Status: $status, Body: ${response.data}');

        // محاولة جلب رسالة الخطأ من الباك اند
        if (response.data is Map<String, dynamic> && response.data.containsKey('errors')) {
          final errors = response.data['errors'] as Map<String, dynamic>;
          // نأخذ أول رسالة خطأ موجودة
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
        }
        return 'Registration failed. Please check your input.';
      }
    } catch (e, st) {
      print('⚠️ Register Exception: $e\n$st');
      return 'An error occurred. Please try again.';
    }
  }


  // ==============================
  // 🔹 تسجيل الدخول
  // ==============================


  Future<bool> login(String email, String password) async {
    try {
      final Map<String, dynamic> body = {
        'email': email,
        'password': password,
      };
      final Response response = await _apiService.post(
        ApiEndpoints.login,
        data: body,
      );

      final status = response.statusCode ?? 0;

      if (status == 200) {
        final dynamic raw = response.data;
        final Map<String, dynamic> data =
        (raw is String) ? jsonDecode(raw) as Map<String, dynamic> : Map<String, dynamic>.from(raw);

        String? token;
        try {
          final loginResponse = LoginResponse.fromJson(data);
          token = loginResponse.token ?? data['token']?.toString();
        } catch (_) {
          token = data['token']?.toString();
        }

        print('✅ Login Success → Token: $token');

        if (token != null) {
          // 🟢 حفظ التوكن في SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);

          // 🟢 تعيينه في ApiService فورًا
          _apiService.setAuthToken(token);
        }

        return true;
      } else {
        print('❌ Login Failed → Status: $status, Body: ${response.data}');
        return false;
      }
    } catch (e, st) {
      print('⚠️ Login Exception: $e\n$st');
      return false;
    }
  }

}
