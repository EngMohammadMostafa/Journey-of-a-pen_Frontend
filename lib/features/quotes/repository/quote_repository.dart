import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_endpoints.dart';
import '../models/quote_model.dart';

class QuoteRepository {
  // 📚 جلب جميع الاقتباسات
  Future<List<Quote>> fetchQuotes() async {
    final response = await http.get(Uri.parse(ApiEndpoints.getQuotes));

    if (response.statusCode == 200) {
      final List quotesJson = json.decode(response.body)['quotes'];
      return quotesJson.map((json) => Quote.fromJson(json)).toList();
    } else {
      throw Exception('فشل في تحميل الاقتباسات');
    }
  }

  // ✨ إضافة اقتباس جديد
  Future<Quote> addQuote(String text, String bookName, int userId) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.getQuotes),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'text': text,
        'book_name': bookName,
        'userid': userId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Quote.fromJson(json.decode(response.body));
    } else {
      throw Exception('فشل في إضافة الاقتباس');
    }
  }
}
