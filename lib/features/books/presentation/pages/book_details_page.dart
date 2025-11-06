import 'package:flutter/material.dart';
import '../../data/models/book_model.dart';
import 'payment_page.dart';
import 'book_reader_page.dart'; 

class BookDetailsPage extends StatefulWidget {
  final BookModel book;
  const BookDetailsPage({super.key, required this.book});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  double _rating = 0;

  void _onBuyPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(book: widget.book),
      ),
    );
  }

  void _onReadPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookReaderPage(book: widget.book),
      ),
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
            // صورة الكتاب
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  book.imageUrl ?? '',
                  height: 250,
                  width: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // الاسم + المؤلف
            Text(
              book.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C597B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "المؤلف: ${book.author}",
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 16),

            // الوصف
            Text(
              book.description ?? "لا يوجد وصف متاح.",
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 20),

            if (book.isPaid)
              Text(
                "السعر: \$9.99",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 30),

            // زر الشراء أو القراءة
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  book.isPaid ? Colors.redAccent : const Color(0xFF1C597B),
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

            // ⭐ تقييم
            const Text(
              "تقييم الكتاب:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => setState(() => _rating = index + 1.0),
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
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
