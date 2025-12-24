import 'dart:io';
import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer2/advance_pdf_viewer.dart';
import '../../data/pdf_service.dart';

class CompetitionBookReaderPage extends StatefulWidget {
  final int bookId;
  final String title;

  const CompetitionBookReaderPage({
    super.key,
    required this.bookId,
    required this.title,
  });

  @override
  State<CompetitionBookReaderPage> createState() =>
      _CompetitionBookReaderPageState();
}

class _CompetitionBookReaderPageState extends State<CompetitionBookReaderPage> {
  bool _loading = true;
  PDFDocument? _document;
  String _loadingText = "جاري تحميل الكتاب...";

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      setState(() {
        _loadingText = "جاري تحميل الملف...";
      });

      final File file = await PdfService.downloadCompetitionBook(
        context: context,
        bookId: widget.bookId,
        title: widget.title,
      );

      setState(() {
        _loadingText = "جاري تجهيز العرض...";
      });

      final document = await PDFDocument.fromFile(file);

      setState(() {
        _document = document;
        _loading = false;
      });

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل تحميل الكتاب")),
      );

      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF1C597B),
      ),
      body: _loading
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            _loadingText,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1C597B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      )
          : _document == null
          ? const Center(child: Text("لا يمكن عرض الملف"))
          : PDFViewer(document: _document!),
    );
  }
}
