import 'package:dio/dio.dart';
import '../../../../../core/api/api_service.dart';
import 'models/book_model.dart';
import 'models/purchase_model.dart';

class BooksService {
  final ApiService _api = ApiService();

  // ----------------------------
  // 1) Fetch all books
  // ----------------------------
  Future<List<BookModel>> fetchBooks() async {
    final response = await _api.get('/api/books');
    final data = response.data as Map<String, dynamic>;

    final booksList = data['books'] as List<dynamic>;
    return booksList.map((json) => BookModel.fromJson(json)).toList();
  }

  // ----------------------------
  // 2) Fetch single book
  // ----------------------------
  Future<BookModel> fetchBookById(int id) async {
    final response = await _api.get('/api/books/$id');
    final data = response.data as Map<String, dynamic>;

    return BookModel.fromJson(data['book']);
  }

  // ----------------------------
  // 3) Fetch books by category
  // ----------------------------
  Future<List<BookModel>> fetchBooksByCategory(int categoryId) async {
    final response =
    await _api.get('/api/categories/$categoryId/books');
    final data = response.data as Map<String, dynamic>;

    final booksList = data['books'] as List<dynamic>;
    return booksList.map((json) => BookModel.fromJson(json)).toList();
  }

  // ----------------------------
  // 4) Purchase a book
  // ----------------------------
  Future<PurchaseModel> purchaseBook(int id) async {
    final response = await _api.post('/api/books/$id/purchase');
    return PurchaseModel.fromJson(response.data);
  }

  // ----------------------------
  // 5) Create purchase
  // ----------------------------
  Future<PurchaseModel> createPurchase({
    required int bookId,
    required String paymentMethod,
  }) async {
    final response = await _api.post('/api/purchases', data: {
      'book_id': bookId,
      'payment_method': paymentMethod,
    });

    return PurchaseModel.fromJson(response.data);
  }
}
