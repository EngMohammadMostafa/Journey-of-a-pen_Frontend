import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../data/models/book_model.dart';

class BookReaderPage extends StatefulWidget {
  final BookModel book;

  const BookReaderPage({super.key, required this.book});

  @override
  State<BookReaderPage> createState() => _BookReaderPageState();
}

class _BookReaderPageState extends State<BookReaderPage> {
  String? fileContent; // نص الكتاب للعرض
  bool isLoading = true;
  String? errorMessage;
  bool offlineMode = false;

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  Future<void> _loadBook() async {
    try {
      // تحقق من أن لدينا رابط تحميل
      if (widget.book.downloadUrl == null) {
        setState(() {
          isLoading = false;
          errorMessage = "رابط الكتاب غير متاح";
        });
        return;
      }

      // تحديد مسار التخزين المحلي
      final dir = await getApplicationDocumentsDirectory();
      final localFile = File("${dir.path}/${widget.book.id}.txt");

      // إذا كان الملف موجود مسبقًا → offline
      if (await localFile.exists()) {
        fileContent = await localFile.readAsString();
        offlineMode = true;
      } else {
        // تحميل الكتاب من الانترنت
        final response = await http.get(Uri.parse(widget.book.downloadUrl!));
        if (response.statusCode == 200) {
          fileContent = response.body;

          // حفظ نسخة للقراءة بدون انترنت
          await localFile.writeAsBytes(response.bodyBytes);
          offlineMode = false;
        } else {
          errorMessage = "فشل تحميل الكتاب: ${response.statusCode}";
        }
      }
    } catch (e) {
      errorMessage = "حدث خطأ أثناء تحميل الكتاب: $e";
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C597B),
        title: Text(widget.book.title),
        actions: [
          if (!isLoading && fileContent != null)
            IconButton(
              icon: Icon(offlineMode ? Icons.cloud_done : Icons.download),
              tooltip: offlineMode
                  ? "تقرأ من النسخة المحفوظة"
                  : "تم تحميل الكتاب للقراءة دون انترنت",
              onPressed: () {},
            )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SelectableText(
            fileContent ?? "",
            style: const TextStyle(fontSize: 18, height: 1.6),
          ),
        ),
      ),
    );
  }
}
