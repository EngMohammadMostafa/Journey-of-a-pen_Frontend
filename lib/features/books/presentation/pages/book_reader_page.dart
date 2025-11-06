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
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🖼️ صورة الكتاب
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    book.imageUrl ?? '',
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
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

              // ✍️ محتوى تجريبي للكتاب
              const Text(
                """في عالمٍ تملؤه الأحلام والخيال، وُلد بطلنا الصغير وهو يحمل شغفًا غريبًا بالكتب. 
كان يجد في الصفحات عوالم لا تنتهي، يسافر بينها وكأنه يعبر إلى أبعادٍ أخرى. 
وذات يوم، وبينما كان يتصفح إحدى الكتب القديمة، عثر على عبارة غامضة تقول: 
"من يقرأ هذه الكلمات، يمتلك مفاتيح العوالم السبعة"...""",
                style: TextStyle(
                  fontSize: 18,
                  height: 1.8,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),
              const Text(
                """واصل القراءة ليتعمق في المغامرة، ويكتشف أسرار تلك الكلمات السحرية التي غيّرت حياته إلى الأبد...""",
                style: TextStyle(
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
