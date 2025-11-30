import 'package:flutter/material.dart';

class QuoteCard extends StatelessWidget {
  final String quoteText;
  final String bookName;

  const QuoteCard({
    required this.quoteText,
    required this.bookName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        title: Text(
          quoteText,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          ' $bookName',
          style: const TextStyle(color: Color(0xFF1C597B)),
        ),
      ),
    );
  }
}
