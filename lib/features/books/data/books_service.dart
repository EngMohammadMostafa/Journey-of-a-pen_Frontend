import '../../../../../core/api/api_service.dart';
import 'models/book_model.dart';
import 'models/purchase_model.dart';

class BooksService {
  final ApiService _api;

  BooksService(this._api); // <-- تمرير ApiService من الخارج

  // جلب كل الكتب
  Future<List<BookModel>> fetchBooks() async {
    final response = await _api.get('/books');
    final data = response.data as Map<String, dynamic>;

    final booksList = data['books'] as List<dynamic>;
    return booksList.map((json) => BookModel.fromJson(json)).toList();
  }

  // جلب كتاب محدد حسب ID
  Future<BookModel> fetchBookById(int id) async {
    final response = await _api.get('/books/$id');
    final data = response.data as Map<String, dynamic>;
    return BookModel.fromJson(data['book']);
  }

  // شراء كتاب واحد
  Future<PurchaseModel> purchaseBook(int id) async {
    final response = await _api.post('/books/$id/purchase');
    final data = response.data as Map<String, dynamic>;
    return PurchaseModel.fromJson(data);
  }

  // إنشاء عملية شراء
  Future<PurchaseModel> createPurchase({
    required int bookId,
    required String paymentMethod,
  }) async {
    final response = await _api.post(
      '/api/purchases',
      data: {
        'book_id': bookId,
        'payment_method': paymentMethod,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return PurchaseModel.fromJson(data);
  }

  // جلب الكتب حسب القسم
  Future<List<BookModel>> fetchBooksByCategory(int categoryId) async {
    final response = await _api.get('/categories/$categoryId/books');
    final data = response.data as Map<String, dynamic>;
    final booksList = data['books'] as List<dynamic>;
    return booksList.map((json) => BookModel.fromJson(json)).toList();
  }
}
