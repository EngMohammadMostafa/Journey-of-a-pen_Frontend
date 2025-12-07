import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/book_model.dart';
import '../widgets/payment_success_dialog.dart';
import '../widgets/payment_error_dialog.dart';
import 'book_reader_page.dart';
import 'package:http/http.dart' as http; // لتحميل الكتاب من الإنترنت

class PaymentPage extends StatefulWidget {
  final BookModel book;
  const PaymentPage({super.key, required this.book});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  double balance = 20.0; // رصيد المستخدم الافتراضي
  double bookPrice = 9.99;
  bool isLoading = false; // حالة التحميل

  Future<File> _getLocalFile(BookModel book) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/${book.id}.txt'; // اسم الملف حسب id الكتاب
    return File(path);
  }

  Future<bool> _isBookDownloaded(BookModel book) async {
    final file = await _getLocalFile(book);
    return file.existsSync();
  }

  Future<void> _downloadBook(BookModel book) async {
    final file = await _getLocalFile(book);

    // هنا نفترض أن الكتاب عبارة عن محتوى نصي من رابط imageUrl (للتجربة)
    // في مشروع حقيقي سيكون رابط الكتاب PDF أو TXT
    final url = book.imageUrl ?? '';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      await file.writeAsBytes(response.bodyBytes);
    } else {
      throw Exception('فشل تحميل الكتاب');
    }
  }

  void _processPayment() async {
    if (balance >= bookPrice) {
      setState(() => balance -= bookPrice);
      showDialog(
        context: context,
        builder: (_) => const PaymentSuccessDialog(),
      );

      setState(() => isLoading = true);

      // تحقق إذا الكتاب محمل مسبقًا
      final isDownloaded = await _isBookDownloaded(widget.book);

      if (!isDownloaded) {
        try {
          await _downloadBook(widget.book);
        } catch (e) {
          setState(() => isLoading = false);
          showDialog(
            context: context,
            builder: (_) => const PaymentErrorDialog(),
          );
          return;
        }
      }

      setState(() => isLoading = false);

      // فتح الكتاب
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookReaderPage(book: widget.book),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => const PaymentErrorDialog(),
      );
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
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text("السعر: \$${bookPrice.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 16, color: Colors.red)),
                const SizedBox(height: 10),
                Text("رصيدك الحالي: \$${balance.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 16, color: Colors.green)),
                const SizedBox(height: 30),

                Center(
                  child: ElevatedButton.icon(
                    onPressed: _processPayment,
                    icon: const Icon(Icons.payment),
                    label: const Text("دفع الآن"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          //  مؤشر التحميل أثناء تنزيل الكتاب
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child:  Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      "جارٍ تحميل الكتاب...",
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
