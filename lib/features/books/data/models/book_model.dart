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
  bool isLikedByUser;
  bool isOwned;
  bool isDownloaded;

  // حالة الإعجاب أثناء انتظار API (UI only)
  bool isLiking; // ← تمت الإضافة

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
    this.isOwned = false,
    this.isDownloaded = false,
    this.isLiking = false, // ← القيمة الافتراضية
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      imageUrl: json['image_url'],
      isPaid: (json['book_type'] ?? 'free') == 'paid',
      categoryName: json['category'] is String
          ? json['category']
          : (json['category']?['name'] ?? "غير محدد"),
      description: json['description'],
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0,
      discountRate: (json['discount_rate'] is num)
          ? (json['discount_rate'] as num).toDouble()
          : 0,
      numberOfLikes: json['likes_count'] ?? json['number_of_likes'] ?? 0,
      filePath: json['file_path'],
      fileType: json['file_type'],
      fileSize: json['file_size'],
      downloadUrl: json['download_url'],
      isLikedByUser: json['is_liked_by_user'] ?? false,
      isOwned: json['owned'] ?? false,
      isDownloaded: json['downloaded_at'] != null,
      isLiking: false, // ← القيمة الافتراضية
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
      'is_liked_by_user': isLikedByUser,
      'owned': isOwned,
      'downloaded': isDownloaded,
    };
  }

  // تحديث حالة الإعجاب
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
