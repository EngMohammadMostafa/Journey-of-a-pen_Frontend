import 'package:flutter/material.dart';
import 'package:book_worm_haven/features/quotes/models/quote_model.dart';

class QuoteCard extends StatelessWidget {
  final String quoteText;
  final String bookName;
  final VoidCallback? onSave;

  const QuoteCard({
    required this.quoteText,
    required this.bookName,
    this.onSave,
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
          '📖 $bookName',
          style: const TextStyle(color: Color(0xFF1C597B)),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download_rounded, color: Color(0xFF1C597B)),
          onPressed: onSave,
          tooltip: 'حفظ في البروفايل',
        ),
      ),
    );
  }
}
