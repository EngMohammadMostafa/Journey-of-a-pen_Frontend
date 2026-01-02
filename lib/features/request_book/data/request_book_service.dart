import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/api/api_service.dart';
import 'models/request_book_model.dart';

class RequestBookService {
  final ApiService _api;

  RequestBookService(this._api);

  // إنشاء طلب كتاب جديد
  Future<RequestBookModel> createRequestBook({
    required String title,
    required String description,
    required String bookType, // free | paid
    int? price,
    required File file,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    _api.setAuthToken(token);

    final formData = FormData.fromMap({
      'title': title,
      'description': description,
      'book_type': bookType,
      if (price != null) 'price': price,
      'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
    });

    final response = await _api.dio.post(
      '/request-books',
      data: formData,
    );

    if (response.statusCode == 201) {
      return RequestBookModel.fromJson(response.data['request_book']);
    } else {
      throw Exception(response.data['message'] ?? 'فشل إنشاء طلب الكتاب');
    }
  }

  // جلب جميع طلبات المستخدم
  Future<List<RequestBookModel>> fetchMyRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    _api.setAuthToken(token);

    final response = await _api.dio.get('/request-books/my-requests');

    if (response.statusCode == 200) {
      final data = response.data as List<dynamic>;
      return data.map((json) => RequestBookModel.fromJson(json)).toList();
    } else {
      throw Exception('فشل تحميل الطلبات');
    }
  }

  // تحميل ملف طلب كتاب

  Future<File?> downloadRequestFile(RequestBookModel requestBook) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    _api.setAuthToken(token);

    final response = await _api.dio.get<List<int>>(
      '/request-books/${requestBook.requestId}/download',
      options: Options(responseType: ResponseType.bytes),
    );

    if (response.statusCode == 200) {
      final dir = await getApplicationDocumentsDirectory();
      final filePath =
          '${dir.path}/${requestBook.title.replaceAll(" ", "_")}.${requestBook.fileType ?? "pdf"}';
      final file = File(filePath);
      await file.writeAsBytes(response.data!);
      return file;
    } else {
      print('فشل تحميل الملف، كود الحالة: ${response.statusCode}');
      return null;
    }
  }
}
