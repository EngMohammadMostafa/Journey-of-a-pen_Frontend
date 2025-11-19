class BookModel {
  final int id;
  final String title;
  final String author;
  final String? imageUrl;
  final bool isPaid;
  final String category;
  final String? description;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    this.imageUrl,
    required this.isPaid,
    required this.category,
    this.description,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      imageUrl: json['image_url'] ?? '', // يتوافق مع API
      isPaid: json['is_paid'] ?? false,
      category: json['category'] ?? 'غير محدد',
      description: json['description'] ?? 'لا يوجد وصف متاح.',
    );
  }
}
