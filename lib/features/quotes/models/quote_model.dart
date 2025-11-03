class Quote {
  final int id;
  final String text;
  final DateTime createdAt;
  final Author author;

  Quote({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.author,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'],
      text: json['text'],
      createdAt: DateTime.parse(json['created_at']),
      author: Author.fromJson(json['author']),
    );
  }
}

class Author {
  final int id;
  final String username;

  Author({required this.id, required this.username});

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'],
      username: json['username'],
    );
  }
}
