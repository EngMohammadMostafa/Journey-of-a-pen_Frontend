class NotificationModel {
  final int notificationId;
  final String title;
  final String content;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;
//  حالة محلية فقط (لا تأتي من الباك)
  bool isNew;

  NotificationModel({
    required this.notificationId,
    required this.title,
    required this.content,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.isNew = true,
  });

// From JSON (Laravel الى Flutter)
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notification_id'],
      title: json['title'],
      content: json['content'],
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isNew: true,
    );
  }

//To JSON (Flutter الى Laravel)
  Map<String, dynamic> toJson() {
    return {
      'notification_id': notificationId,
      'title': title,
      'content': content,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
