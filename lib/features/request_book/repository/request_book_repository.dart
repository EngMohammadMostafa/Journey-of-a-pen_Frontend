import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_service.dart';
import '../../../core/constants/api_endpoints.dart';
import '../data/models/request_book_model.dart';

class RequestBookRepository {
  final ApiService _api;

  RequestBookRepository(this._api);

  // إعداد التوكن

  Future<void> setAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    if (token.isNotEmpty) {
      _api.setAuthToken(token);
    }
  }

  // جلب جميع طلبات المستخدم

  Future<List<RequestBookModel>> fetchMyRequests() async {
    try {
      await setAuthToken();

      final response = await _api.get(ApiEndpoints.myRequests);

      final List<dynamic> data = response.data is String
          ? jsonDecode(response.data)
          : response.data as List<dynamic>;

      return data
          .map((json) => RequestBookModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // إنشاء طلب كتاب جديد

  Future<RequestBookModel> createRequestBook({
    required String title,
    required String description,
    required String bookType, // free | paid
    int? price,
    required File file,
  }) async {
    try {
      await setAuthToken();

      final formData = FormData.fromMap({
        'title': title,
        'description': description,
        'book_type': bookType,
        if (price != null) 'price': price,
        'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
      });


      final dio = _api.dio;
      final response = await dio.post(
        ApiEndpoints.requestBooks,
        data: formData,
      );

      return RequestBookModel.fromJson(response.data['request_book']);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // تحميل ملف طلب كتاب

  Future<File?> downloadRequestFile(RequestBookModel requestBook) async {
    try {
      await setAuthToken();

      final dio = _api.dio;
      final response = await dio.get<List<int>>(
        '/request-books/${requestBook.requestId}/download',
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        final dir = Directory.systemTemp;
        final filePath =
            '${dir.path}/${requestBook.title.replaceAll(" ", "_")}.${requestBook.fileType ?? "pdf"}';
        final file = File(filePath);
        await file.writeAsBytes(response.data!);
        return file;
      } else {
        throw Exception('فشل تحميل الملف');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // معالجة الأخطاء

  String _handleError(DioException e) {
    if (e.response != null) {
      return 'Server error: ${e.response?.statusCode} → ${e.response?.data}';
    } else {
      return 'Connection error: ${e.message}';
    }
  }
}
