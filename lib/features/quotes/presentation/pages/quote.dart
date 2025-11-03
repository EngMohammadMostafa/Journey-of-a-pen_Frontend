import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:book_worm_haven/features/quotes/models/quote_model.dart';
import 'package:book_worm_haven/features/quotes/repository/quote_repository.dart';
import '../widgets/quote_card.dart'; // استدعاء الـ Widget الجديد

class QuotesPage extends StatefulWidget {
  @override
  _QuotesPageState createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> {
  final TextEditingController _quoteController = TextEditingController();
  final TextEditingController _bookController = TextEditingController();
  final QuoteRepository _repository = QuoteRepository();

  List<Quote> _quotes = [];
  List<Quote> _savedQuotes = [];

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    try {
      final quotes = await _repository.fetchQuotes();
      setState(() {
        _quotes = quotes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في جلب الاقتباسات')),
      );
    }
  }

  void _showAddQuoteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 60),
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
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud, color: Color(0xFF4C869F), size: 55),
                      SizedBox(height: 10),
                      Text(
                        'أضف اقتباسًا جديدًا',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C597B),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _quoteController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'نص الاقتباس',
                          labelStyle: TextStyle(color: Color(0xFF1C597B)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.8)),
                          ),
                        ),
                        style: TextStyle(color: Color(0xFF1C597B)),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: _bookController,
                        decoration: InputDecoration(
                          labelText: 'اسم الكتاب',
                          labelStyle: TextStyle(color: Color(0xFF1C597B)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.8)),
                          ),
                        ),
                        style: TextStyle(color: Color(0xFF1C597B)),
                      ),
                      SizedBox(height: 25),
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (_quoteController.text.isNotEmpty &&
                              _bookController.text.isNotEmpty) {
                            try {
                              final newQuote = await _repository.addQuote(
                                  _quoteController.text,
                                  _bookController.text,
                                  1); // ضع هنا User ID الحقيقي
                              setState(() {
                                _quotes.add(newQuote);
                              });
                              _quoteController.clear();
                              _bookController.clear();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('تم نشر الاقتباس بنجاح!'),
                                  backgroundColor: Color(0xFF1C597B),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('فشل في نشر الاقتباس'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        icon: Icon(Icons.cloud_upload, color: Colors.white),
                        label: Text('نشر', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1C597B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
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

  void _saveQuote(int index) async {
    final selectedQuote = _quotes[index];
    try {
      await _repository.saveQuote(selectedQuote.id, 1); // ضع هنا User ID الحقيقي
      if (!_savedQuotes.contains(selectedQuote)) {
        setState(() {
          _savedQuotes.add(selectedQuote);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ الاقتباس في ملفك الشخصي!'),
            backgroundColor: Color(0xFF1C597B),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('هذا الاقتباس محفوظ مسبقًا.'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء حفظ الاقتباس'),
          backgroundColor: Colors.grey,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الاقتباسات',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF000000),
        elevation: 4,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddQuoteDialog,
        backgroundColor: Color(0xFF1C597B),
        child: Icon(Icons.add, size: 30),
      ),
      body: Stack(
        children: [
          // 🌈 الخلفية بالتدرج
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
          // ⚪️ الدوائر الزخرفية
          Positioned(
            right: -20,
            bottom: 20,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.10),
              ),
            ),
          ),
          Positioned(
            right: 60,
            bottom: 60,
            child: Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            right: 80,
            bottom: 30,
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // 📚 قائمة الاقتباسات باستخدام الـ Widget
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _quotes.isEmpty
                ? Center(
              child: Text(
                'لا توجد اقتباسات حتى الآن',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            )
                : ListView.builder(
              itemCount: _quotes.length,
              itemBuilder: (context, index) {
                return QuoteCard(
                  quoteText: _quotes[index].text,
                  bookName: _quotes[index].author.username,
                  onSave: () => _saveQuote(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
