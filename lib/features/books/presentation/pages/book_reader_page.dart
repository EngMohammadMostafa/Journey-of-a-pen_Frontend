import 'package:flutter/material.dart';
import '../../data/models/book_model.dart';

class BookReaderPage extends StatelessWidget {
  final BookModel book;

  const BookReaderPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C597B),
        title: Text(book.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: book.content == null || book.content!.isEmpty
            ? const Center(
          child: Text(
            "لا يوجد محتوى متاح لهذا الكتاب بعد.",
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
        )
            : SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🖼️ صورة الغلاف (اختياري)
              if (book.imageUrl != null && book.imageUrl!.isNotEmpty)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      book.imageUrl!,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (book.imageUrl != null && book.imageUrl!.isNotEmpty)
                const SizedBox(height: 20),

              // 📖 العنوان والمؤلف
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
                "تأليف: ${book.author}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const Divider(height: 30, thickness: 1),

              // ✍️ محتوى الكتاب الحقيقي
              Text(
                book.content!,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.8,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 40),

              // 🕮 زر للخروج
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("العودة إلى تفاصيل الكتاب"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C597B),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
