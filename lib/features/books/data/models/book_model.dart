class BookModel {
  final int id;
  final String title;
  final String author;
  final String? description;
  final String bookType; // free / paid
  final int categoryId;
  final double price;
  final double discountRate;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    this.description,
    required this.bookType,
    required this.categoryId,
    required this.price,
    required this.discountRate,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      description: json['description'],
      bookType: json['book_type'],
      categoryId: json['category_id'],
      price: (json['price'] ?? 0).toDouble(),
      discountRate: (json['discount_rate'] ?? 0).toDouble(),
    );
  }
}
