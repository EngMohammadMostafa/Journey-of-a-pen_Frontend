import 'package:flutter/material.dart';
import '../../books/data/books_service.dart';
import '../../books/data/models/book_model.dart';

class HomeProvider extends ChangeNotifier {
  final BooksService _booksService;

  HomeProvider(this._booksService);

  List<BookModel> _books = [];
  String _searchQuery = '';
  int? _selectedCategoryId;

  List<BookModel> get books => _books;
  String get searchQuery => _searchQuery;

  // جلب كل الكتب من API
  Future<void> fetchAllBooks() async {
    try {
      final response = await _booksService.fetchBooks();
      _books = response;
    } catch (e) {
      print("Error fetching books: $e");
      _books = []; // تعيين قائمة فارغة عند الخطأ
    } finally {
      notifyListeners();
    }
  }

  // تحديث البحث
  void updateSearch(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  // اختيار التصنيف
  void selectCategory(int? id) {
    _selectedCategoryId = id;
    notifyListeners();
  }

  // فلترة الكتب حسب البحث والتصنيف
  List<BookModel> get filteredBooks {
    List<BookModel> result = _books;

    if (_selectedCategoryId != null) {
      result = result.where((b) => b.categoryId == _selectedCategoryId).toList();
    }

    if (_searchQuery.isNotEmpty) {
      result = result.where((b) {
        final title = b.title.toLowerCase();
        final author = b.author.toLowerCase();
        final desc = b.description?.toLowerCase() ?? "";
        return title.contains(_searchQuery) ||
            author.contains(_searchQuery) ||
            desc.contains(_searchQuery);
      }).toList();
    }

    return result;
  }

  // ==============================
  // دالة للحصول على رابط تحميل الكتاب
  // ==============================
  Future<String?> getDownloadLink(BookModel book, {String? userToken}) async {
    try {
      final link = await _booksService.getDownloadLink(book, userToken: userToken);
      return link;
    } catch (e) {
      print("Error getting download link for book ${book.id}: $e");
      return null;
    }
  }
}
