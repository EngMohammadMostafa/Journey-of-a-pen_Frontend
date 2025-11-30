import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:book_worm_haven/features/quotes/presentation/widgets/quote_card.dart';
import '../../../../core/api/api_service.dart';
import '../../../../core/utils/prefs_helper.dart';
import '../../models/quote_model.dart';
import '../../repository/quote_repository.dart';


class QuotesPage extends StatefulWidget {
  @override
  _QuotesPageState createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> {
  final TextEditingController _quoteController = TextEditingController();
  final TextEditingController _bookController = TextEditingController();

  final QuoteRepository _quoteRepo = QuoteRepository();

  List<Quote> _quotes = [];
  bool _isLoading = true;

  // ============================
  // استرجاع التوكن عند فتح الصفحة
  // ============================
  Future<void> _initAuth() async {
    final token = await PrefsHelper.getToken();
    if (token != null) {
      ApiService().setAuthToken(token);
      print(' Token restored from storage: $token');
    }
  }

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  // ============================
  // استدعاء التوكن أولاً ثم جلب الاقتباسات
  // ============================
  Future<void> _initializePage() async {
    await _initAuth();  // ← استرجاع التوكن أولاً
    await _fetchQuotes(); // ← ثم جلب الاقتباسات
  }

  Future<void> _fetchQuotes() async {
    try {
      final quotes = await _quoteRepo.fetchQuotes();
      setState(() {
        _quotes = quotes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تحميل الاقتباسات: $e')),
      );
    }
  }

  Future<void> _addQuote() async {
    if (_quoteController.text.isEmpty || _bookController.text.isEmpty) return;

    try {
      const int userId = 1; // مؤقتًا
      final newQuote = await _quoteRepo.addQuote(
        _quoteController.text,
        _bookController.text,
        userId,
      );

      setState(() {
        _quotes.insert(0, newQuote);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم نشر الاقتباس بنجاح!'),
          backgroundColor: Color(0xFF1C597B),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في النشر: $e')),
      );
    } finally {
      _quoteController.clear();
      _bookController.clear();
      Navigator.pop(context);
    }
  }

  void _showAddQuoteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.8),
                    width: 1.3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.25),
                      blurRadius: 25,
                      spreadRadius: -5,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud, color: Color(0xFF4C869F), size: 55),
                      const SizedBox(height: 10),
                      const Text(
                        'أضف اقتباسًا جديدًا',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C597B),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _quoteController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'نص الاقتباس',
                          labelStyle: const TextStyle(color: Color(0xFF1C597B)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _bookController,
                        decoration: InputDecoration(
                          labelText: 'اسم الكتاب',
                          labelStyle: const TextStyle(color: Color(0xFF1C597B)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton.icon(
                        onPressed: _addQuote,
                        icon: const Icon(Icons.cloud_upload, color: Colors.white),
                        label: const Text('نشر', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C597B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الاقتباسات',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF000000),
        elevation: 4,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddQuoteDialog,
        backgroundColor: const Color(0xFF1C597B),
        child: const Icon(Icons.add, size: 30),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF000000),
                  Color(0xFF7199AA),
                  Color(0xFF4C869F),
                  Color(0xFF1C597B),
                ],
              ),
            ),
          ),
          _isLoading
              ? const Center(
            child: CircularProgressIndicator(color: Colors.white),
          )
              : Padding(
            padding: const EdgeInsets.all(16.0),
            child: _quotes.isEmpty
                ? const Center(
              child: Text(
                'لا توجد اقتباسات حتى الآن',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
                : ListView.builder(
              itemCount: _quotes.length,
              itemBuilder: (context, index) {
                final quote = _quotes[index];
                return QuoteCard(
                  quoteText: quote.text,
                  bookName: quote.bookName ?? 'غير معروف',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
