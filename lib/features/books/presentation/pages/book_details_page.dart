import 'package:flutter/material.dart';
import '../../data/models/book_model.dart';

class BookDetailsPage extends StatefulWidget {
  final BookModel book;
  const BookDetailsPage({super.key, required this.book});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  double _rating = 0;

  void _onBuyPressed() {
    Navigator.pushNamed(context, '/payment', arguments: widget.book);
  }

  void _onReadPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("فتح ${widget.book.title}...")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        backgroundColor: const Color(0xFF1C597B),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  book.imageUrl ?? '',
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              book.title,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C597B)),
            ),
            Text(
              "المؤلف: ${book.author}",
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Text(
              book.description ?? "لا يوجد وصف متاح لهذا الكتاب.",
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),

            if (book.isPaid)
              Text(
                "السعر: \$9.99",
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),

            const SizedBox(height: 20),

            // زر الشراء أو القراءة
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  book.isPaid ? Colors.red : const Color(0xFF1C597B),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(book.isPaid ? Icons.shopping_cart : Icons.menu_book),
                label: Text(book.isPaid ? "شراء الآن" : "تحميل وقراءة"),
                onPressed: book.isPaid ? _onBuyPressed : _onReadPressed,
              ),
            ),

            const SizedBox(height: 30),

            // ⭐ التقييم
            Text(
              "تقييم الكتاب:",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800]),
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => setState(() => _rating = index + 1.0),
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 30,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}