import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/books_service.dart';
import '../data/models/book_model.dart';
import '../data/models/purchase_model.dart';
import '../../../../../core/api/api_service.dart';

class BooksRepository extends ChangeNotifier {
  final BooksService _service;
  final ApiService _api;

  BooksRepository(ApiService api)
      : _service = BooksService(api),
        _api = api;

  // 🔹 جلب كل الكتب
  Future<List<BookModel>> getAllBooks() => _service.fetchBooks();

  // 🔹 جلب كتاب محدد
  Future<BookModel> getBookById(int id) => _service.fetchBookById(id);

  // 🔹 شراء كتاب
  Future<PurchaseModel> purchaseBook(int id) => _service.purchaseBook(id);

  // 🔹 إنشاء عملية شراء
  Future<PurchaseModel> createPurchase(int bookId, String method) =>
      _service.createPurchase(bookId: bookId, paymentMethod: method);

  // 🔹 جلب كتب حسب القسم
  Future<List<BookModel>> getBooksByCategory(int categoryId) =>
      _service.fetchBooksByCategory(categoryId);

  // 🔹 دالة للحصول على رابط التحميل لكل كتاب مع التحقق من تسجيل الدخول
  Future<String?> getDownloadLink(BookModel book, {String? userToken}) async {
    try {
      // إذا لم يتم تمرير التوكن، نحاول جلبه من SharedPreferences
      String? token = userToken;
      if (token == null) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString('token');
      }

      if (token == null) {
        print("❌ لا يمكن جلب رابط التحميل → المستخدم غير مسجل الدخول");
        return null;
      }

      // إضافة التوكن للـ ApiService قبل الطلب
      _api.setAuthToken(token);

      // استدعاء الـ endpoint باستخدام ApiService مباشرة
      final res = await _api.post('/books/${book.id}/download');

      if (res.statusCode == 200 && res.data['success'] == true) {
        book.downloadUrl = res.data['download_url'];
        notifyListeners();
        return book.downloadUrl;
      }

      return null;
    } catch (e) {
      print("Error generating download link: $e");
      return null;
    }
  }
}
