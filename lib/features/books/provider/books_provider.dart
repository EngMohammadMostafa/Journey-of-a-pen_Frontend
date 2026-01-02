import 'package:flutter/foundation.dart';
import '../../../core/utils/prefs_helper.dart';
import '../data/models/book_model.dart';
import '../data/models/purchase_model.dart';
import '../repository/books_repository.dart';

class BooksProvider extends ChangeNotifier {
  final BooksRepository _repository;

  BooksProvider({required BooksRepository repository}) : _repository = repository;

  bool loading = false;
  String? error;

  List<BookModel> books = [];
  BookModel? selectedBook;

  List<PurchaseModel> purchasedBooks = [];

  // جلب جميع الكتب وتهيئة البيانات بعد تسجيل الدخول
  Future<void> initializeUserData() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      books = await _repository.getAllBooks();
      await loadPurchasesFromLocal();
      await _loadDownloadedBooksLocally();

      final List<PurchaseModel> serverPurchases = await _repository.getPurchasedBooks();

      for (var purchase in serverPurchases) {
        if (purchase.book != null &&
            !purchasedBooks.any((p) => p.book?.id == purchase.book!.id)) {
          purchasedBooks.add(purchase);
        }
      }

      await _updateBooksOwnership();

      final purchasedIds = purchasedBooks.map((p) => p.book!.id).toList();
      await PrefsHelper.setPurchasedBookIds(purchasedIds);

    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadPurchasesFromLocal() async {
    final purchasedIds = await PrefsHelper.getPurchasedBookIds();

    for (var book in books) {
      if (purchasedIds.contains(book.id)) {
        book.isOwned = true;
      }
    }

    purchasedBooks = books
        .where((b) => purchasedIds.contains(b.id))
        .map((b) => PurchaseModel(
      book: b,
      message: "تمت إضافته محليًا",
      purchasedAt: DateTime.now(),
    ))
        .toList();

    notifyListeners();
  }

  Future<void> _loadDownloadedBooksLocally() async {
    final ids = await PrefsHelper.getDownloadedBookIds();
    for (var book in books) {
      if (ids.contains(book.id)) {
        book.isOwned = true;
        book.isDownloaded = true;

        final file = await PrefsHelper.getBookFile(book.id);
        if (file != null) {
          book.downloadUrl = file.path;
        }
      }
    }
  }

  Future<void> _updateBooksOwnership() async {
    Set<int> purchasedIds = purchasedBooks.map((p) => p.book!.id).toSet();
    final localPurchasedIds = await PrefsHelper.getPurchasedBookIds();
    purchasedIds.addAll(localPurchasedIds);

    for (var book in books) {
      if (purchasedIds.contains(book.id)) {
        book.isOwned = true;
      }
    }
    notifyListeners();
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

        final downloadedIds = await PrefsHelper.getDownloadedBookIds();
        if (!downloadedIds.contains(book.id)) downloadedIds.add(book.id);
        await PrefsHelper.setDownloadedBookIds(downloadedIds);

        final purchasedIds = await PrefsHelper.getPurchasedBookIds();
        if (!purchasedIds.contains(book.id)) purchasedIds.add(book.id);
        await PrefsHelper.setPurchasedBookIds(purchasedIds);

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

  Future<void> loadPurchasedBooksFromServer() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      final List<PurchaseModel> serverPurchases = await _repository.getPurchasedBooks();
      purchasedBooks = serverPurchases;

      for (var purchase in purchasedBooks) {
        if (purchase.book != null) {
          final index = books.indexWhere((b) => b.id == purchase.book!.id);
          if (index != -1) books[index].isOwned = true;
        }
      }

      final purchasedIds = purchasedBooks.map((p) => p.book!.id).toList();
      await PrefsHelper.setPurchasedBookIds(purchasedIds);

    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

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
      await _updateBooksOwnership();

    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> purchaseBook(BookModel book) async {
    if (book.isOwned) return true;

    try {
      loading = true;
      error = null;
      notifyListeners();

      final PurchaseModel result = await _repository.purchaseBook(book.id);

      book.isOwned = true;

      if (result.book != null) {
        purchasedBooks.add(result);
        await _updateBooksOwnership();

        final purchasedIds = purchasedBooks
            .where((p) => p.book != null)
            .map((p) => p.book!.id)
            .toList();
        await PrefsHelper.setPurchasedBookIds(purchasedIds);
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

  bool canBuy(BookModel book) => book.isPaid && !book.isOwned;
  bool canDownload(BookModel book) => book.isOwned && !book.isDownloaded;
  bool canOpen(BookModel book) => book.isDownloaded;

  void reset() {
    books = [];
    selectedBook = null;
    loading = false;
    error = null;
    notifyListeners();
  }
}
