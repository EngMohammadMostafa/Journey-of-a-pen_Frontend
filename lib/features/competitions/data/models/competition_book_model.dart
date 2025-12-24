import 'user_lite_model.dart';

class CompetitionBookModel {
  final int id;
  final int? competitionId;
  final int? userId;
  final String title;
  final String? filePath;
  final String? fileType;
  final int? fileSize;
  final int likesCount;

  // تظهر فقط في admin APIs
  final UserLiteModel? owner;
  final List<UserLiteModel>? likedUsers;

  CompetitionBookModel({
    required this.id,
    this.competitionId,
    this.userId,
    required this.title,
    this.filePath,
    this.fileType,
    this.fileSize,
    required this.likesCount,
    this.owner,
    this.likedUsers,
  });

  factory CompetitionBookModel.fromJson(Map<String, dynamic> json) {
    return CompetitionBookModel(
      id: json['competition_book_id'],
      competitionId: json['competition_id'],
      userId: json['user_id'],
      title: json['title'],
      filePath: json['file_path'],
      fileType: json['file_type'],
      fileSize: json['file_size'],
      likesCount: json['likes_count'] ?? 0,
      owner: json['owner'] != null
          ? UserLiteModel.fromJson(json['owner'])
          : null,
      likedUsers: json['liked_users'] != null
          ? (json['liked_users'] as List)
          .map((e) => UserLiteModel.fromJson(e))
          .toList()
          : null,
    );
  }

  CompetitionBookModel copyWith({
    int? likesCount,
  }) {
    return CompetitionBookModel(
      id: id,
      competitionId: competitionId,
      userId: userId,
      title: title,
      filePath: filePath,
      fileType: fileType,
      fileSize: fileSize,
      likesCount: likesCount ?? this.likesCount,
      owner: owner,
      likedUsers: likedUsers,
    );
  }
}
