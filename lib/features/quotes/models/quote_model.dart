class Quote {
  final int id;
  final String text;
  final String bookName;
  final DateTime createdAt;

  Quote({
    required this.id,
    required this.text,
    required this.bookName,
    required this.createdAt,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'],
      text: json['text'],
      bookName: json['book_name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
