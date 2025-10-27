import 'package:dio/dio.dart';
import '../../../../../core/api/api_service.dart';
import 'models/book_model.dart';
import 'models/purchase_model.dart';


class BooksService {
  final ApiService _api = ApiService();

  Future<List<BookModel>> fetchBooks() async {
    final response = await _api.get('/api/books');
    final data = response.data;
    final booksList = data['books'] as List;
    return booksList.map((json) => BookModel.fromJson(json)).toList();
  }

  Future<BookModel> fetchBookById(int id) async {
    final response = await _api.get('/api/books/$id');
    return BookModel.fromJson(response.data['books'][0]);
  }

  Future<PurchaseModel> purchaseBook(int id) async {
    final response = await _api.post('/api/books/$id/purchase');
    return PurchaseModel.fromJson(response.data);
  }

  Future<PurchaseModel> createPurchase({required int bookId, required String paymentMethod}) async {
    final response = await _api.post('/api/purchases', data: {
      'book_id': bookId,
      'payment_method': paymentMethod,
    });
    return PurchaseModel.fromJson(response.data);
  }
}
