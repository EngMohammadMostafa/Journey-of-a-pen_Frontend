class BookModel {
  final int id;
  final String title;
  final String author;
  final String? imageUrl;
  final bool isPaid;
  final String categoryName;
  final String? description;

  // الحقول المالية
  final double price;
  final double discountRate;
  int numberOfLikes; // قابل للتغيير عند الإعجاب/إلغاء الإعجاب

  // ملفات الكتاب
  String? filePath;
  final String? fileType;
  final int? fileSize;
  String? downloadUrl;

  // 🔥 حالة الإعجاب من قبل المستخدم الحالي
  bool isLikedByUser;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    this.imageUrl,
    required this.isPaid,
    required this.categoryName,
    this.description,
    this.price = 0,
    this.discountRate = 0,
    this.numberOfLikes = 0,
    this.filePath,
    this.fileType,
    this.fileSize,
    this.downloadUrl,
    this.isLikedByUser = false,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      imageUrl: json['image_url'],
      isPaid: (json['book_type'] ?? 'free') == 'paid',
      categoryName: json['category'] ?? "غير محدد",
      description: json['description'] ?? 'لا يوجد وصف متاح.',
      price: (json['price'] ?? 0).toDouble(),
      discountRate: (json['discount_rate'] ?? 0).toDouble(),
      numberOfLikes: json['likes_count'] ?? 0,
      filePath: json['file_path'],
      fileType: json['file_type'],
      fileSize: json['file_size'],
      downloadUrl: json['download_url'],
      isLikedByUser: json['is_liked_by_user'] ?? false, // 🔥 جديد
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'image_url': imageUrl,
      'book_type': isPaid ? 'paid' : 'free',
      'category': categoryName,
      'description': description,
      'price': price,
      'discount_rate': discountRate,
      'number_of_likes': numberOfLikes,
      'file_path': filePath,
      'file_type': fileType,
      'file_size': fileSize,
      'download_url': downloadUrl,
      'is_liked_by_user': isLikedByUser, // 🔥 جديد
    };
  }

  // تحديث حالة الإعجاب وعدد الإعجابات بعد نقر المستخدم
  void toggleLike() {
    if (isLikedByUser) {
      numberOfLikes = (numberOfLikes > 0) ? numberOfLikes - 1 : 0;
      isLikedByUser = false;
    } else {
      numberOfLikes += 1;
      isLikedByUser = true;
    }
  }
}
