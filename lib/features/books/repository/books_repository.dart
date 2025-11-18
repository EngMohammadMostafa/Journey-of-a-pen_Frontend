import '../data/books_service.dart';
import '../data/models/book_model.dart';
import '../data/models/purchase_model.dart';

class BooksRepository {
  final BooksService _service = BooksService();

  Future<List<BookModel>> getAllBooks() => _service.fetchBooks();

  Future<BookModel> getBookById(int id) => _service.fetchBookById(id);

  Future<PurchaseModel> purchaseBook(int id) => _service.purchaseBook(id);

  Future<PurchaseModel> createPurchase(int bookId, String method) =>
      _service.createPurchase(bookId: bookId, paymentMethod: method);

  Future<List<BookModel>> getBooksByCategory(int categoryId) =>
      _service.fetchBooksByCategory(categoryId);
}
