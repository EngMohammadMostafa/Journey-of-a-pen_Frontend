import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quote_model.dart';

class QuoteRepository {
  final String baseUrl = 'https://your-backend.com/api'; // عدلي الرابط هنا

  Future<List<Quote>> fetchQuotes() async {
    final response = await http.get(Uri.parse('$baseUrl/quotes'));
    if (response.statusCode == 200) {
      final List quotesJson = json.decode(response.body)['quotes'];
      return quotesJson.map((json) => Quote.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load quotes');
    }
  }

  Future<Quote> addQuote(String text, String bookName, int userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/quotes'),
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
      throw Exception('Failed to post quote');
    }
  }

  // ✅ إضافة دالة لحفظ الاقتباس في بروفايل المستخدم
  Future<void> saveQuote(int quoteId, int userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/quotes/save'), // عدلي endpoint حسب الباك اند
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'quote_id': quoteId,
        'user_id': userId,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to save quote');
    }
  }
}
