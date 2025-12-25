import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/book_model.dart';
import '../../provider/books_provider.dart';
import 'book_reader_page.dart';

class PaymentPage extends StatefulWidget {
  final BookModel book;
  const PaymentPage({super.key, required this.book});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool isLoading = false;
  String? errorMessage;

  // ===========================
  // معالجة الدفع وفتح الكتاب
  // ===========================
  void _processPayment() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final booksProvider = context.read<BooksProvider>();
    final book = widget.book;

    try {
      // محاولة شراء الكتاب إذا كان مدفوعًا ولم يشترِ بعد
      if (book.isPaid && !book.isOwned) {
        bool purchased = await booksProvider.purchaseBook(book);
        if (!purchased) throw Exception("فشل شراء الكتاب");
      }

      // تحميل الكتاب أو الحصول على رابط التحميل
      final downloadLink = await booksProvider.downloadBook(book);
      if (downloadLink == null) throw Exception("فشل تحميل الكتاب");

      // بعد الدفع والتحقق/تحميل الكتاب، افتح الكتاب
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BookReaderPage(book: book),
          ),
        );
      }
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    return Scaffold(
      appBar: AppBar(
        title: const Text("إتمام عملية الدفع"),
        backgroundColor: const Color(0xFF1C597B),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "الكتاب: ${book.title}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "السعر: \$${book.price.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _processPayment,
                    icon: const Icon(Icons.payment),
                    label: const Text("دفع وفتح الكتاب"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ]
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      "جارٍ معالجة الدفع وتحميل الكتاب...",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
