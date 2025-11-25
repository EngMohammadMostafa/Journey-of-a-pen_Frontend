class BookModel {
  final int id;
  final String title;
  final String author;
  final String? imageUrl;
  final bool isPaid;
  final int categoryId;
  final String categoryName;
  final String? description;

  // الحقول الجديدة
  final double price;
  final double discountRate;
  final int numberOfLikes;
  final String? filePath;
  final String? fileType;
  final int? fileSize;
  String? downloadUrl; // يمكن تحديثه لاحقًا عند طلب رابط التحميل

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    this.imageUrl,
    required this.isPaid,
    required this.categoryId,
    required this.categoryName,
    this.description,
    this.price = 0,
    this.discountRate = 0,
    this.numberOfLikes = 0,
    this.filePath,
    this.fileType,
    this.fileSize,
    this.downloadUrl,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    return BookModel(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      imageUrl: json['image_url'], // إذا موجود
      isPaid: (json['book_type'] ?? 'free') == 'paid',
      categoryId: category != null ? category['id'] : 0,
      categoryName: category != null ? category['name'] : "غير محدد",
      description: json['description'] ?? 'لا يوجد وصف متاح.',
      price: (json['price'] ?? 0).toDouble(),
      discountRate: (json['discount_rate'] ?? 0).toDouble(),
      numberOfLikes: json['number_of_likes'] ?? 0,
      filePath: json['file_path'],
      fileType: json['file_type'],
      fileSize: json['file_size'],
      downloadUrl: json['download_url'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'image_url': imageUrl,
      'book_type': isPaid ? 'paid' : 'free',
      'category': {
        'id': categoryId,
        'name': categoryName,
      },
      'description': description,
      'price': price,
      'discount_rate': discountRate,
      'number_of_likes': numberOfLikes,
      'file_path': filePath,
      'file_type': fileType,
      'file_size': fileSize,
      'download_url': downloadUrl,
    };
  }
}
