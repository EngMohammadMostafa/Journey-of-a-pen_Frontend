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
  // جلب جميع الكتب وتهيئة البيانات بعد تسجيل الدخول
  // =========================
  Future<void> initializeUserData() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      // 1. جلب جميع الكتب
      books = await _repository.getAllBooks();

      // 1.5 تحميل المشتريات المحفوظة محليًا
      await loadPurchasesFromLocal();

      // 2. تحميل الكتب المحملة محليًا
      await _loadDownloadedBooksLocally();

      // 3. جلب المشتريات من الباك
      final serverPurchases = (await _repository.getPurchasedBooks()).cast<PurchaseModel>();

      // دمج المشتريات الجديدة من السيرفر مع المشتريات المحفوظة محليًا
      for (var purchase in serverPurchases) {
        if (purchase.book != null &&
            !purchasedBooks.any((p) => p.book?.id == purchase.book!.id)) {
          purchasedBooks.add(purchase);
        }
      }

      // 4. تحديث الملكية حسب المشتريات
      await _updateBooksOwnership();

      // 5. حفظ IDs المشتريات محليًا
      final purchasedIds = purchasedBooks
          .where((p) => p.book != null)
          .map((p) => p.book!.id)
          .toList();
      await PrefsHelper.setPurchasedBookIds(purchasedIds);

    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // =========================
  // تحميل المشتريات المحفوظة محليًا
  // =========================
  Future<void> loadPurchasesFromLocal() async {
    final purchasedIds = await PrefsHelper.getPurchasedBookIds();

    // تحديث حالة الملكية في الكتب
    for (var book in books) {
      if (purchasedIds.contains(book.id)) {
        book.isOwned = true;
      }
    }

    // إنشاء قائمة purchasedBooks مؤقتًا بدون بيانات الباك
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
  }

  // =========================
  // تحديث حالة الملكية حسب المشتريات
  // =========================
  Future<void> _updateBooksOwnership() async {
    Set<int> purchasedIds = purchasedBooks
        .where((p) => p.book != null)
        .map((p) => p.book!.id)
        .toSet();

    // إضافة IDs المشتريات المحفوظة محليًا
    final localPurchasedIds = await PrefsHelper.getPurchasedBookIds();
    purchasedIds.addAll(localPurchasedIds);

    for (var book in books) {
      if (purchasedIds.contains(book.id)) {
        book.isOwned = true;
      }
    }
    notifyListeners();
  }

  // =========================
  // تحميل كتاب
  // =========================
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

        // تحديث قائمة الكتب المحملة محليًا
        final downloadedIds = await PrefsHelper.getDownloadedBookIds();
        if (!downloadedIds.contains(book.id)) downloadedIds.add(book.id);
        await PrefsHelper.setDownloadedBookIds(downloadedIds);

        // تحديث قائمة المشتريات محليًا
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

  // =========================
  // باقي الدوال كما هي
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
      await _updateBooksOwnership();

    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> purchaseBook(BookModel book) async {
    if (book.isOwned) {
      // الكتاب مملوك مسبقًا، لا حاجة لإعادة الشراء
      return true;
    }

    try {
      loading = true;
      error = null;
      notifyListeners();

      final PurchaseModel result = await _repository.purchaseBook(book.id);

      book.isOwned = true;

      if (result.book != null) {
        purchasedBooks.add(result);
        await _updateBooksOwnership();

        // حفظ المشتريات محليًا
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
