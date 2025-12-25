class RequestBookModel {
  final int requestId;
  final int userId;
  final String title;
  final String description;
  final String bookType; // free | paid
  final int price;
  final String filePath;
  final String fileType;
  final int fileSize;
  final String status; // pending | accepted | rejected

  RequestBookModel({
    required this.requestId,
    required this.userId,
    required this.title,
    required this.description,
    required this.bookType,
    required this.price,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    required this.status,
  });

  factory RequestBookModel.fromJson(Map<String, dynamic> json) {
    return RequestBookModel(
      requestId: json['request_id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      bookType: json['book_type'],
      price: json['price'] ?? 0,
      filePath: json['file_path'],
      fileType: json['file_type'],
      fileSize: json['file_size'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'user_id': userId,
      'title': title,
      'description': description,
      'book_type': bookType,
      'price': price,
      'file_path': filePath,
      'file_type': fileType,
      'file_size': fileSize,
      'status': status,
    };
  }
}
