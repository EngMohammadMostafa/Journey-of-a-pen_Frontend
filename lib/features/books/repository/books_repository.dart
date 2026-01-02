import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/prefs_helper.dart';
import '../data/models/book_model.dart';
import '../data/models/purchase_model.dart';

class BooksRepository {
  final ApiService api;

  BooksRepository(this.api);

  // جلب الكتب المشتراة من الباك
  Future<List<PurchaseModel>> getPurchasedBooks() async {
    final response = await api.get(ApiEndpoints.purchasedBooks);
    final data = response.data['books'] as List<dynamic>;
    final purchases = data.map((json) {
      final book = BookModel.fromJson(json);
      return PurchaseModel(
          book: book,
          purchasedAt: DateTime.now(), // يمكن التعديل إذا الباك يعيد تاريخ الشراء
          message: "تم شراؤه"
      );
    }).toList();

    // حفظ الكتب المشتراة محليًا
    final purchasedIds = purchases.map((p) => p.book!.id).toList();
    await PrefsHelper.setPurchasedBookIds(purchasedIds);

    return purchases;
  }

  // جلب جميع الكتب
  Future<List<BookModel>> getAllBooks() async {
    final response = await api.get(ApiEndpoints.allBooks);
    final data = response.data['books'] as List<dynamic>;
    return data.map((json) => BookModel.fromJson(json)).toList();
  }

  // جلب كتاب واحد
  Future<BookModel> getBookById(int id) async {
    final response = await api.get(ApiEndpoints.bookDetails(id));
    return BookModel.fromJson(response.data['book']);
  }

  // جلب الكتب حسب القسم
  Future<List<BookModel>> getBooksByCategory(int categoryId) async {
    final response = await api.get(ApiEndpoints.booksByCategory(categoryId));
    final data = response.data['books'] as List<dynamic>;
    return data.map((json) => BookModel.fromJson(json)).toList();
  }

  // شراء كتاب
  Future<PurchaseModel> purchaseBook(int bookId) async {
    final response = await api.post(ApiEndpoints.purchaseBook(bookId));
    return PurchaseModel.fromJson(response.data);
  }

  // تحميل كتاب و تسجيله محليًا
  Future<String?> downloadAndRegisterBook(BookModel book) async {
    try {
      final response = await api.post(ApiEndpoints.downloadBook(book.id));
      final downloadUrl = response.data['download_url'] as String?;

      if (downloadUrl != null) {
        final bytes = await _downloadFile(downloadUrl);
        await PrefsHelper.saveBookContent(book.id, bytes);

        final ids = await PrefsHelper.getDownloadedBookIds();
        if (!ids.contains(book.id)) {
          ids.add(book.id);
          await PrefsHelper.setDownloadedBookIds(ids);
        }

        return downloadUrl;
      }

      return null;
    } catch (e) {
      throw Exception("فشل تحميل الكتاب: $e");
    }
  }

  Future<List<int>> _downloadFile(String url) async {
    final response = await Dio().get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data!;
  }
}
