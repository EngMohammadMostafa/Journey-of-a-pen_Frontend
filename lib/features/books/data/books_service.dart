import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/api/api_service.dart';
import 'models/book_model.dart';
import 'models/purchase_model.dart';

class BooksService {
  final ApiService _api;

  BooksService(this._api);

  // ==========================
  // جلب كل الكتب
  // ==========================
  Future<List<BookModel>> fetchBooks() async {
    final response = await _api.get('/books');
    final data = response.data as Map<String, dynamic>;
    final booksList = data['books'] as List<dynamic>;
    return booksList.map((json) => BookModel.fromJson(json)).toList();
  }

  // ==========================
  // جلب كتاب محدد حسب ID
  // ==========================
  Future<BookModel> fetchBookById(int id) async {
    final response = await _api.get('/books/$id');
    final data = response.data as Map<String, dynamic>;
    return BookModel.fromJson(data['book']);
  }

  // ==========================
  // شراء كتاب
  // ==========================
  Future<PurchaseModel> purchaseBook(int id) async {
    final response = await _api.post('/books/$id/purchase');
    final data = response.data as Map<String, dynamic>;
    return PurchaseModel.fromJson(data);
  }

  // ==========================
  // إنشاء عملية شراء
  // ==========================
  Future<PurchaseModel> createPurchase({
    required int bookId,
    required String paymentMethod,
  }) async {
    final response = await _api.post(
      '/purchases',
      data: {
        'book_id': bookId,
        'payment_method': paymentMethod,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return PurchaseModel.fromJson(data);
  }

  // ==========================
  // جلب الكتب حسب القسم
  // ==========================
  Future<List<BookModel>> fetchBooksByCategory(int categoryId) async {
    final response = await _api.get('/categories/$categoryId/books');
    final data = response.data as Map<String, dynamic>;
    final booksList = data['books'] as List<dynamic>;
    return booksList.map((json) => BookModel.fromJson(json)).toList();
  }

  // ==========================
  // الحصول على رابط التحميل لكل كتاب
  // ==========================
  Future<String?> getDownloadLink(BookModel book, {String? userToken}) async {
    try {
      String? token = userToken;

      // جلب التوكن من SharedPreferences إذا لم يمرر من الخارج
      if (token == null) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString('token');
      }

      if (token == null || token.isEmpty) {
        print("لا يمكن جلب رابط التحميل → المستخدم غير مسجل الدخول");
        return null;
      }

      // ضبط التوكن في ApiService قبل الطلب
      _api.setAuthToken(token);

      // إرسال طلب POST بدون تمرير options
      final res = await _api.post('/books/${book.id}/download');

      if (res.statusCode == 200 && res.data['success'] == true) {
        book.downloadUrl = res.data['download_url'];
        return book.downloadUrl;
      } else {
        print("فشل الحصول على رابط التحميل: ${res.data['message'] ?? 'خطأ غير معروف'}");
      }

      return null;
    } catch (e) {
      print("Error generating download link: $e");
      return null;
    }
  }


}
