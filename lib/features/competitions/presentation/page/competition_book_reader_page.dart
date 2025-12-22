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

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final File file = await PdfService.downloadCompetitionBook(
        context: context,
        bookId: widget.bookId,
        title: widget.title,
      );

      _document = await PDFDocument.fromFile(file);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل تحميل الكتاب")),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF1C597B),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _document == null
          ? const Center(child: Text("لا يمكن عرض الملف"))
          : PDFViewer(document: _document!),
    );
  }
}
