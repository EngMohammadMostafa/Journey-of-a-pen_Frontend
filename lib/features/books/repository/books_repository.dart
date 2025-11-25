import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../data/books_service.dart';
import '../data/models/book_model.dart';
import '../data/models/purchase_model.dart';

class BooksRepository extends ChangeNotifier {
  final BooksService _service = BooksService();

  BooksRepository();

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

  // 🔹 دالة للحصول على رابط التحميل لكل كتاب
  Future<String?> getDownloadLink(BookModel book, String userToken) async {
    try {
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $userToken';

      // استدعاء API توليد رابط التحميل
      final res = await dio.get(
        'https://your-api.com/api/books/${book.id}/generateDownloadLink',
      );

      if (res.statusCode == 200 && res.data['success'] == true) {
        // تحديث الـ downloadUrl في الكتاب
        book.downloadUrl = res.data['download_url'];
        notifyListeners(); // يمكن تحديث UI إذا كان هناك زر يعتمد على الرابط
        return book.downloadUrl;
      }

      return null;
    } catch (e) {
      print("Error generating download link: $e");
      return null;
    }
  }
}
