import 'dart:io';
import 'package:advance_pdf_viewer2/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../profile/provider/profile_provider.dart';
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
      final filePath = "${dir.path}/${widget.book.id}.pdf";
      final file = File(filePath);

      // 🔥 1) لو الملف موجود → افتحه بدون إنترنت
      if (await file.exists()) {
        document = await PDFDocument.fromFile(file);
        Provider.of<ProfileProvider>(context, listen: false)
            .addDownloadedBook(widget.book);

        localPdfPath = filePath;
        offlineMode = true;

        setState(() => isLoading = false);
        return;
      }

      // 🔥 2) لو ما كان موجود → تحميل مرة واحدة فقط
      final response = await http.get(Uri.parse(widget.book.downloadUrl!));

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);

        localPdfPath = filePath;
        offlineMode = false;

        document = await PDFDocument.fromFile(file);
      } else {
        errorMessage = "فشل تحميل الكتاب: ${response.statusCode}";
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
          if (!isLoading && document != null)
            IconButton(
              icon: Icon(
                offlineMode ? Icons.cloud_done : Icons.download_done_outlined,
              ),
              tooltip: offlineMode
                  ? "تقرأ نسخة بدون إنترنت"
                  : "تم تحميل الكتاب وتخزينه محليًا",
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
          ? const Center(child: Text("لم يتم العثور على الملف"))
          : PDFViewer(
        document: document!,
        zoomSteps: 1,
        scrollDirection: Axis.vertical,
        lazyLoad: false, // يمنع تحميل الصفحات اللاحق
        showPicker: false,
      ),
    );
  }
}
