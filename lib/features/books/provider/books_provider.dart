import 'package:flutter/foundation.dart';
import '../../../core/utils/prefs_helper.dart';
import '../data/models/book_model.dart';
import '../data/models/purchase_model.dart';
import '../repository/books_repository.dart';

class BooksProvider extends ChangeNotifier {
  final BooksRepository _repository;

  BooksProvider({required BooksRepository repository})
      : _repository = repository;

  bool loading = false;
  String? error;

  List<BookModel> books = [];
  BookModel? selectedBook;

  List<PurchaseModel> purchasedBooks = [];

  // =========================
  // جلب جميع الكتب
  // =========================
  Future<void> loadBooks() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      books = await _repository.getAllBooks();

      // تحديث حالة الكتب المحملة محليًا
      await _loadDownloadedBooksLocally();

      // تحديث حالة الملكية حسب المشتريات
      _updateBooksOwnership();

    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // =========================
  // جلب المشتريات من الباك
  // =========================
  Future<void> fetchPurchasedBooks() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      purchasedBooks = (await _repository.getPurchasedBooks()).cast<PurchaseModel>();

      // تحديث حالة الملكية بعد جلب المشتريات
      _updateBooksOwnership();

    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // =========================
  // تحميل الكتب المحملة محليًا عند فتح التطبيق
  // =========================
  Future<void> _loadDownloadedBooksLocally() async {
    final ids = await PrefsHelper.getDownloadedBookIds();
    for (var book in books) {
      if (ids.contains(book.id)) {
        book.isOwned = true;
        book.isDownloaded = true;

        // قراءة الملف المحلي
        final file = await PrefsHelper.getBookFile(book.id);
        if (file != null) {
          book.downloadUrl = file.path;
        }
      }
    }
    notifyListeners();
  }

  // =========================
  // تحديث حالة الملكية حسب المشتريات
  // =========================
  void _updateBooksOwnership() {
    // اجمع كل IDs للكتب المشتراة، مع التأكد أن book ليس null
    final purchasedIds = purchasedBooks
        .where((p) => p.book != null)
        .map((p) => p.book!.id)
        .toSet();

    for (var book in books) {
      if (purchasedIds.contains(book.id)) {
        book.isOwned = true;
      }
    }
    notifyListeners();
  }
  // =========================
  // باقي الدوال كما هي دون أي تعديل
  // =========================
  Future<void> loadBookById(int id) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      selectedBook = await _repository.getBookById(id);

    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadBooksByCategory(int categoryId) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      books = await _repository.getBooksByCategory(categoryId);

      // تحديث حالة الملكية حسب المشتريات بعد تحميل الكتب حسب القسم
      _updateBooksOwnership();

    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
  Future<bool> purchaseBook(BookModel book) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      final PurchaseModel result = await _repository.purchaseBook(book.id);

      // ضع الكتاب كـ owned
      book.isOwned = true;

      if (result.book != null) {
        purchasedBooks.add(result);
        _updateBooksOwnership();
      }

      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }


  Future<String?> downloadBook(BookModel book) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      final link = await _repository.downloadAndRegisterBook(book);

      if (link != null) {
        book.downloadUrl = link;
        book.isOwned = true;
        book.isDownloaded = true;
        notifyListeners();
      }

      return link;

    } catch (e) {
      error = e.toString();
      notifyListeners();
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<String?> fetchDownloadLink(BookModel book) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      final link = await _repository.downloadAndRegisterBook(book);

      if (link != null) {
        book.downloadUrl = link;
        book.isOwned = true;
        book.isDownloaded = true;
        notifyListeners();
      }

      return link;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  bool canBuy(BookModel book) => book.isPaid && !book.isOwned;

  bool canDownload(BookModel book) =>
      book.isOwned && !book.isDownloaded;

  bool canOpen(BookModel book) => book.isDownloaded;

  void reset() {
    books = [];
    selectedBook = null;
    loading = false;
    error = null;
    notifyListeners();
  }
}
