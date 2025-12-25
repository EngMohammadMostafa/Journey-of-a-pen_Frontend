import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/book_model.dart';
import '../../provider/books_provider.dart';
import 'payment_page.dart';
import 'book_reader_page.dart';

class BookDetailsPage extends StatefulWidget {
  final BookModel book;
  const BookDetailsPage({super.key, required this.book});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  bool _loadingAction = false;

  // =========================
  // زر الشراء أو القراءة أو التحميل
  // =========================
  void _onActionPressed() async {
    final booksProvider = context.read<BooksProvider>();
    final book = widget.book;

    setState(() {
      _loadingAction = true;
    });

    try {
      // إذا الكتاب مملوك بالفعل
      if (book.isOwned) {
        // تحميل الكتاب إذا لم يكن محمّل
        if (!book.isDownloaded) {
          final downloadLink = await booksProvider.downloadBook(book);
          if (downloadLink != null) {
            setState(() {}); // تحديث الزر بعد التحميل
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("تم تحميل الكتاب بنجاح!")),
            );
          }
        }

        // فتح الكتاب إذا تم تحميله
        if (book.isDownloaded) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BookReaderPage(book: book)),
          );
        }
        return;
      }

      // إذا الكتاب مدفوع ولم يتم شراؤه
      if (book.isPaid && !book.isOwned) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PaymentPage(book: book)),
        );

        // إذا تم الشراء بنجاح، تحديث حالة الكتاب مباشرة
        if (result == true) {
          setState(() {
            book.isOwned = true;
          });
        }
        return;
      }

      // إذا الكتاب مجاني ولم يتم تحميله بعد
      final downloadLink = await booksProvider.downloadBook(book);
      if (downloadLink != null) {
        setState(() {}); // تحديث الزر بعد التحميل
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BookReaderPage(book: book)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ: $e")),
      );
    } finally {
      setState(() {
        _loadingAction = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          book.title,
          style: const TextStyle(fontFamily: 'Papyrus', fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1C597B),
        elevation: 0,
      ),
      body: SafeArea(
        child: SizedBox.expand(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1C597B),
                  Color(0xFF4C869F),
                  Color(0xFF7199AA),
                  Color(0xFFE3F2FD),
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: kToolbarHeight + 16),

                  // بطاقة معلومات الكتاب
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Papyrus',
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "by ${book.author}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontFamily: 'Papyrus',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          book.description ?? "No description available.",
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            height: 1.5,
                            fontFamily: 'Papyrus',
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (book.isPaid)
                          Text(
                            "Price: \$${book.price.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.amberAccent,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Papyrus',
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // زر الشراء / القراءة / التحميل
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: book.isOwned
                          ? Colors.green
                          : (book.isPaid ? Colors.redAccent : const Color(0xFF1C597B)),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    icon: _loadingAction
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : Icon(
                      book.isOwned
                          ? (book.isDownloaded ? Icons.menu_book : Icons.download)
                          : (book.isPaid ? Icons.shopping_cart : Icons.menu_book),
                      size: 24,
                    ),
                    label: Text(
                      _loadingAction
                          ? "Loading..."
                          : book.isOwned
                          ? (book.isDownloaded ? "Open Book" : "Download Book")
                          : (book.isPaid ? "Buy Now" : "Read Now"),
                      style: const TextStyle(
                        fontFamily: 'Papyrus',
                        fontSize: 18,
                      ),
                    ),
                    onPressed: _loadingAction ? null : _onActionPressed,
                  ),

                  const SizedBox(height: 35),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
