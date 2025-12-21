import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/api/api_service.dart';
import '../../../../core/constants/api_endpoints.dart';
import 'models/competition_book_model.dart';
import 'models/competition_model.dart';

class CompetitionService {
  final ApiService _api;

  CompetitionService(this._api);

  // ==========================
  // جلب كل المسابقات
  // ==========================
  Future<List<CompetitionModel>> fetchCompetitions() async {
    final response = await _api.get(ApiEndpoints.competitions);

    final data = response.data as Map<String, dynamic>;
    final list = data['competitions'] as List<dynamic>;

    return list
        .map((json) => CompetitionModel.fromJson(json))
        .toList();
  }

  // ==========================
  // جلب تفاصيل مسابقة واحدة
  // ==========================
  Future<CompetitionModel> fetchCompetitionById(int id) async {
    final response = await _api.get('${ApiEndpoints.competitions}/$id');
    final data = response.data as Map<String, dynamic>;

    return CompetitionModel.fromJson(data['competition']);
  }

  // ==========================
  // المشاركة في مسابقة (رفع كتاب)
  // ==========================
  Future<bool> participateInCompetition({
    required int competitionId,
    required String title,
    required String filePath,
  }) async {
    try {
      final file = await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      );

      final response = await _api.post(
        '${ApiEndpoints.competitions}/$competitionId/participate',
        data: {
          'title': title,
          'file': file,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      print('Participation error: ${e.message}');
      return false;
    }
  }

  // ==========================
  // جلب كتب المسابقة
  // ==========================
  Future<List<CompetitionBookModel>> fetchCompetitionBooks(int competitionId) async {
    final response = await _api.get(
      '${ApiEndpoints.competitions}/$competitionId/books',
    );

    final data = response.data as Map<String, dynamic>;
    final list = data['books'] as List<dynamic>;

    return list
        .map((json) => CompetitionBookModel.fromJson(json))
        .toList();
  }

  // ==========================
  // تحميل كتاب مسابقة وفتحه
  // ==========================
  Future<File?> downloadAndOpenCompetitionBook(
      CompetitionBookModel book,
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        print('المستخدم غير مسجل الدخول');
        return null;
      }

      _api.setAuthToken(token);

      // طلب رابط التحميل من السيرفر
      final response = await _api.get(
        '${ApiEndpoints.competitions}/books/${book.id}/download',
      );

      if (response.statusCode != 200) return null;

      final downloadUrl = response.data['download_url'];
      if (downloadUrl == null) return null;

      final dir = await getApplicationDocumentsDirectory();
      final filePath =
          '${dir.path}/${book.title.replaceAll(" ", "_")}.pdf';

      final file = File(filePath);

      if (!await file.exists()) {
        final downloadResponse = await Dio().get<List<int>>(
          downloadUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        await file.writeAsBytes(downloadResponse.data!);
      }

      await OpenFile.open(file.path);
      return file;
    } catch (e) {
      print('Download competition book error: $e');
      return null;
    }
  }
}
