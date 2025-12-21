import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';
import '../../../core/constants/api_endpoints.dart';
import '../data/models/competition_model.dart';
import '../data/models/competition_book_model.dart';

class CompetitionRepository {
  final ApiService _api = ApiService();

  // ===============================
  //  جلب المسابقات المتاحة
  // ===============================
  Future<List<CompetitionModel>> getCompetitions() async {
    try {
      final response = await _api.get(ApiEndpoints.competitions);

      final Map<String, dynamic> data = response.data is String
          ? jsonDecode(response.data)
          : response.data as Map<String, dynamic>;

      final List<dynamic> list = data['competitions'] ?? [];

      return list
          .map((e) => CompetitionModel.fromJson(e))
          .toList();

    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ===============================
  //  جلب كتب مسابقة معينة
  // ===============================
  Future<List<CompetitionBookModel>> getCompetitionBooks(int competitionId) async {
    try {
      final response = await _api.get(
        ApiEndpoints.competitionBooks(competitionId),
      );

      final Map<String, dynamic> data = response.data is String
          ? jsonDecode(response.data)
          : response.data as Map<String, dynamic>;

      final List<dynamic> list = data['books'] ?? [];

      return list
          .map((e) => CompetitionBookModel.fromJson(e))
          .toList();

    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ===============================
  //  المشاركة في المسابقة (رفع كتاب)
  // ===============================
  Future<void> participate({
    required int competitionId,
    required String title,
    required String filePath,
  }) async {
    try {
      final file = await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      );

      final Map<String, dynamic> body = {
        'title': title,
        'file': file,
      };

      await _api.post(
        ApiEndpoints.participateInCompetition(competitionId),
        data: body,
      );

    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }
  // ===============================
  //  لايك / إلغاء لايك
  // ===============================
  Future<_LikeResult> toggleLike(int competitionBookId) async {
    try {
      final response = await _api.post(
        ApiEndpoints.likeCompetitionBook(competitionBookId),
      );

      final Map<String, dynamic> data = response.data is String
          ? jsonDecode(response.data)
          : response.data as Map<String, dynamic>;

      return _LikeResult(
        liked: data['liked'] ?? false,
        likesCount: data['likes_count'] ?? 0,
      );

    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ===============================
  //  تحميل كتاب مسابقة
  // ===============================
  Future<void> downloadCompetitionBook(int competitionBookId) async {
    try {
      await _api.get(
        ApiEndpoints.downloadCompetitionBook(competitionBookId),
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }


  // ===============================
  //  ربط التوكن (إن احتجته)
  // ===============================
  void setAuthToken(String token) {
    _api.setAuthToken(token);
  }

  // ===============================
  //  Error Handler (نفس مشروعك)
  // ===============================
  String _handleError(DioException e) {
    if (e.response != null) {
      return 'Server error: ${e.response?.statusCode} → ${e.response?.data}';
    } else {
      return 'Connection error: ${e.message}';
    }
  }
}

// ==================================
//  كلاس داخلي لنتيجة اللايك
// ==================================
class _LikeResult {
  final bool liked;
  final int likesCount;

  _LikeResult({
    required this.liked,
    required this.likesCount,
  });
}
