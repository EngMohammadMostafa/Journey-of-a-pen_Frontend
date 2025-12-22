import 'dart:io';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class PdfService {
  static Future<void> downloadAndOpen({
    required int bookId,
    required String title,
    required String token,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$title.pdf';
      final file = File(filePath);

      // إذا الملف موجود ➜ افتح مباشرة
      if (await file.exists()) {
        await OpenFile.open(filePath);
        return;
      }

      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await dio.download(
        'http://127.0.0.1:8000/api/competition-books/$bookId/download',
        filePath,
      );

      if (response.statusCode == 200) {
        await OpenFile.open(filePath);
      } else {
        throw Exception('فشل التحميل');
      }

    } catch (e) {
      rethrow;
    }
  }
}
