import 'package:book_worm_haven/features/question/presentation/pages/quiz_page.dart';
import 'package:flutter/material.dart';
import '../../../books/data/models/book_model.dart';

class PurchasedBooksSection extends StatefulWidget {
  final List<BookModel> books;
  final void Function(BookModel)? onBookTap;

  const PurchasedBooksSection({
    super.key,
    required this.books,
    this.onBookTap,
  });
  @override
  State<PurchasedBooksSection> createState() => _PurchasedBooksSectionState();
}

class _PurchasedBooksSectionState extends State<PurchasedBooksSection> {
  // تخزين حالة كل كتاب: هل أنهى الأسئلة أم لا
  Map<int, bool> quizCompleted = {};

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1C597B), Color(0xFF4C869F), Color(0xFF7199AA)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  ' الكتب المدفوعة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: widget.books.length,
                itemBuilder: (context, index) {
                  final book = widget.books[index]; // تعريف book هنا داخل itemBuilder

                  return Card(
                    color: Colors.white.withOpacity(0.15),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: ListTile(
                      title: Text(
                        book.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        book.author,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      onTap: () {
                        if (widget.onBookTap != null) {
                          widget.onBookTap!(book); // عند النقر على الكتاب
                        }
                      },
                      trailing: quizCompleted[index] == true
                          ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                          : ElevatedButton(
                        onPressed: () {
                          if (quizCompleted[index] == true) return;
                          _openQuiz(context, index); // index موجود داخل itemBuilder
                        },
                        child: const Text('Quiz'),
                      ),
                    ),
                  );
                },
              ),
            ),

              ],
            ),
          ),
        );
      },
    );
  }

  void _openQuiz(BuildContext context, int bookIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizPage(
          bookId: widget.books[bookIndex].id, // ← نمرّر معرف الكتاب هنا
          onCompleted: () {
            setState(() => quizCompleted[bookIndex] = true);
          },
        ),
      ),
    );
  }
}


