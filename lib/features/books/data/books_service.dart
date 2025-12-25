import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/api/api_service.dart';
import 'models/book_model.dart';
import 'models/purchase_model.dart';

class BooksService {
  final ApiService _api;

  BooksService(this._api);

  // ==========================
  // جلب كل الكتب
  // ==========================
  Future<List<BookModel>> fetchBooks() async {
    final response = await _api.get('/books');
    final data = response.data as Map<String, dynamic>;
    final booksList = data['books'] as List<dynamic>;
    return booksList.map((json) => BookModel.fromJson(json)).toList();
  }

  // ==========================
  // جلب كتاب محدد حسب ID
  // ==========================
  Future<BookModel> fetchBookById(int id) async {
    final response = await _api.get('/books/$id');
    final data = response.data as Map<String, dynamic>;
    return BookModel.fromJson(data['book']);
  }

  // ==========================
  // شراء كتاب
  // ==========================
  Future<PurchaseModel> purchaseBook(int id) async {
    final response = await _api.post('/books/$id/purchase');
    final data = response.data as Map<String, dynamic>;
    return PurchaseModel.fromJson(data);
  }

  // ==========================
  // جلب الكتب حسب القسم
  // ==========================
  Future<List<BookModel>> fetchBooksByCategory(int categoryId) async {
    final response = await _api.get('/categories/$categoryId/books');
    final data = response.data as Map<String, dynamic>;
    final booksList = data['books'] as List<dynamic>;
    return booksList.map((json) => BookModel.fromJson(json)).toList();
  }

  // ==========================
  // تحميل الكتاب وتسجيله على السيرفر (للكتاب المجاني أو المدفوع بعد الشراء)
  // ==========================
  Future<File?> downloadAndRegisterBook(BookModel book, {String? userToken}) async {
    try {
      String? token = userToken;
      if (token == null) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString('token');
      }

      if (token == null || token.isEmpty) {
        print("المستخدم غير مسجل الدخول");
        return null;
      }

      _api.setAuthToken(token);

      // طلب التحميل من السيرفر (يتحقق من الملكية على السيرفر)
      final response = await _api.post('/books/${book.id}/download');

      if (response.statusCode == 200 &&
          response.data is Map &&
          response.data['download_url'] != null) {
        book.downloadUrl = response.data['download_url'];

        // مجلد التطبيق لحفظ الملف محليًا
        final dir = await getApplicationDocumentsDirectory();
        final safeTitle = book.title.replaceAll(RegExp(r'[^\w\s-]'), '');
        final filePath =
            '${dir.path}/${safeTitle.replaceAll(" ", "_")}.${book.fileType ?? "pdf"}';
        final file = File(filePath);

        // إذا الملف موجود مسبقًا
        if (await file.exists()) {
          book.filePath = file.path;
          return file;
        }

        // تنزيل الكتاب من رابط التحميل
        final downloadResponse = await Dio().get<List<int>>(
          book.downloadUrl!,
          options: Options(responseType: ResponseType.bytes),
        );

        await file.writeAsBytes(downloadResponse.data!);
        book.filePath = file.path;

        return file;
      } else {
        print("لا يمكن تحميل الكتاب: ${response.data['message'] ?? 'غير مسموح'}");
        return null;
      }
    } catch (e) {
      print("Error downloading/registering book: $e");
      return null;
    }
  }

  // ==========================
  // فتح الكتاب (تحميله إذا لم يكن موجودًا محليًا)
  // ==========================
  Future<void> openBook(BookModel book) async {
    if (book.filePath == null) {
      final file = await downloadAndRegisterBook(book);
      if (file == null) return;
    }
    if (book.filePath != null) {
      await OpenFile.open(book.filePath);
    }
  }

  // ==========================
  // Toggle Like / Unlike
  // ==========================
  Future<Map<String, dynamic>> toggleLike(int bookId, {String? userToken}) async {
    try {
      String? token = userToken;
      if (token == null) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString('token');
      }

      if (token == null || token.isEmpty) {
        throw Exception("المستخدم غير مسجل الدخول");
      }

      _api.setAuthToken(token);

      final response = await _api.post('/books/$bookId/toggle-like');

      if (response.statusCode == 200 && response.data is Map) {
        // يحتوي على {success, liked, likes_count}
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'فشل تغيير حالة الإعجاب');
      }
    } catch (e) {
      print("Error toggling like: $e");
      rethrow;
    }
  }
}
