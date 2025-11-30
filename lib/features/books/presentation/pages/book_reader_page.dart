import 'dart:io';
import 'package:advance_pdf_viewer2/advance_pdf_viewer.dart';
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
  String? localPdfPath;
  bool isLoading = true;
  String? errorMessage;
  bool offlineMode = false;
  PDFDocument? document;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      if (widget.book.downloadUrl == null) {
        setState(() {
          isLoading = false;
          errorMessage = "رابط التحميل غير متاح";
        });
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/${widget.book.id}.pdf");

      if (await file.exists()) {
        localPdfPath = file.path;
        offlineMode = true;
      } else {
        final response = await http.get(Uri.parse(widget.book.downloadUrl!));

        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
          localPdfPath = file.path;
          offlineMode = false;
        } else {
          setState(() {
            errorMessage = "فشل تحميل الكتاب: ${response.statusCode}";
            isLoading = false;
          });
          return;
        }
      }

      // تحميل المستند باستخدام advance_pdf_viewer2
      if (localPdfPath != null) {
        document = await PDFDocument.fromFile(File(localPdfPath!));
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
          if (!isLoading && localPdfPath != null)
            IconButton(
              icon: Icon(
                  offlineMode ? Icons.cloud_done : Icons.download_done_outlined),
              tooltip:
              offlineMode ? "تقرأ نسخة بدون إنترنت" : "تم حفظ الكتاب محليًا",
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
          : document == null
          ? const Center(
        child: Text("لم يتم العثور على الملف"),
      )
          : PDFViewer(
        document: document!,
        zoomSteps: 1,
        scrollDirection: Axis.vertical,
        lazyLoad: true,
        showPicker: false,
      ),
    );
  }
}
