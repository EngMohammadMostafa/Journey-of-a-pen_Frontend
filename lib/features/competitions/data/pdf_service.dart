import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../../core/api/api_service.dart';

class PdfService {
  /// تحميل أو فتح كتاب مسابقة PDF
  static Future<void> openCompetitionBook({
    required BuildContext context,
    required int bookId,
    required String title,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$title.pdf';
      final file = File(filePath);

      // إذا كان الملف موجود محليًا → افتحه مباشرة
      if (await file.exists()) {
        await OpenFile.open(file.path);
        return;
      }

      final token = ApiService().token;
      if (token == null) {
        _showSnack(context, 'لم يتم تسجيل الدخول');
        return;
      }

      // ⬇️ تحميل من الباك مع التوكن
      await ApiService().dio.download(
        '/competition-books/$bookId/download',
        filePath,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
          responseType: ResponseType.bytes,
        ),
      );

      await OpenFile.open(filePath);
    } on DioException catch (e) {
      _handleDioError(context, e);
    } catch (e) {
      _showSnack(context, 'حدث خطأ غير متوقع');
    }
  }

  /// تحميل كتاب PDF بدون فتحه مباشرة
  static Future<File> downloadCompetitionBook({
    required BuildContext context,
    required int bookId,
    required String title,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      String safeTitle = title.replaceAll(RegExp(r'[^\w\s-]'), '');
      final filePath = '${dir.path}/$safeTitle-$bookId.pdf';

      final file = File(filePath);

      // ✅ إذا كان الملف موجودًا لا تعيد تحميله
      if (await file.exists()) {
        return file;
      }

      final token = ApiService().token;
      if (token == null) {
        throw Exception('لم يتم تسجيل الدخول');
      }

      // ✅ التحميل الصحيح للـ PDF
      final response = await ApiService().dio.get(
        '/competition-books/$bookId/download',
        options: Options(
          responseType: ResponseType.bytes, // 🔴 مهم جدًا
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/pdf',
          },
        ),
      );

      // ✅ حفظ الـ bytes كملف حقيقي
      await file.writeAsBytes(response.data, flush: true);

      return file;
    } on DioException catch (e) {
      _handleDioError(context, e);
      rethrow;
    } catch (e) {
      _showSnack(context, 'حدث خطأ غير متوقع');
      rethrow;
    }
  }

  // ================== Helpers ==================

  static void _handleDioError(BuildContext context, DioException e) {
    if (e.response == null) {
      _showSnack(context, 'فشل الاتصال بالخادم');
      return;
    }

    switch (e.response!.statusCode) {
      case 403:
        _showSnack(context, 'المسابقة غير متاحة');
        break;
      case 404:
        _showSnack(context, 'الملف غير موجود');
        break;
      default:
        _showSnack(context, 'فشل تحميل الملف');
    }
  }

  static void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
