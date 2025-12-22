import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../../../core/api/api_service.dart';

class PdfService {
  static final Dio _dio = ApiService().dio;

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

      // ✅ إذا كان الملف موجود محليًا → افتحه مباشرة
      if (await file.exists()) {
        await OpenFile.open(file.path);
        return;
      }

      // ⬇️ تحميل من الباك
      await _dio.download(
        '/competition-books/$bookId/download',
        filePath,
      );

      await OpenFile.open(filePath);
    } on DioException catch (e) {
      _handleDioError(context, e);
    } catch (_) {
      _showSnack(context, 'حدث خطأ غير متوقع');
    }
  }

  static Future<File> downloadCompetitionBook({
    required BuildContext context,
    required int bookId,
    required String title,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$title.pdf';
      final file = File(filePath);

      // إذا كان موجود محليًا
      if (await file.exists()) {
        return file;
      }

      // تحميل من الباك
      await ApiService().dio.download(
        '/competition-books/$bookId/download',
        filePath,
      );

      return file;
    } on DioException catch (e) {
      _handleDioError(context, e);
      rethrow;
    } catch (_) {
      _showSnack(context, 'حدث خطأ غير متوقع');
      rethrow;
    }
  }



  // ================== Helpers ==================

  static void _handleDioError(BuildContext context, DioException e) {
    if (e.response == null) {
      _showSnack(context, 'لا يوجد اتصال بالإنترنت');
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
