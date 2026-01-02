import 'package:book_worm_haven/core/api/api_service.dart';
import 'package:book_worm_haven/core/constants/api_endpoints.dart';
import 'package:book_worm_haven/core/utils/prefs_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/quote_model.dart';

class QuoteRepository {
  final ApiService _apiService = ApiService();

  //  جلب جميع الاقتباسات
  Future<List<Quote>> fetchQuotes() async {
    try {
      //  جلب التوكن من SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('لم يتم العثور على التوكن. يُرجى تسجيل الدخول مجددًا.');
      }

      _apiService.setAuthToken(token);

      final response = await _apiService.get(ApiEndpoints.quotes);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['quotes'] ?? [];
        return data.map((q) => Quote.fromJson(q)).toList();
      } else {
        throw Exception('فشل في تحميل الاقتباسات (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('حدث خطأ أثناء تحميل الاقتباسات: $e');
    }
  }
  //  إضافة اقتباس جديد
  Future<Quote> addQuote(String text, String bookName, int userId) async {
    try {
      //  جلب التوكن من SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('لم يتم العثور على التوكن. يُرجى تسجيل الدخول مجددًا.');
      }

      //  إعداد التوكن في ApiService
      _apiService.setAuthToken(token);

      //  إرسال البيانات
      final response = await _apiService.post(
        ApiEndpoints.quotes,
        data: {
          'text': text,
          'book_name': bookName,
          'user_id': userId,
        },
      );

      final data = response.data;

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        return Quote.fromJson(data['quote']);
      } else {
        throw Exception(data['message'] ?? 'فشل في إضافة الاقتباس.');
      }
    } catch (e) {
      throw Exception('حدث خطأ أثناء إضافة الاقتباس: $e');
    }
  }
}
