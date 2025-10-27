import 'dart:ui';
import 'package:flutter/material.dart';

class QuotesPage extends StatefulWidget {
  @override
  _QuotesPageState createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> {
  final TextEditingController _quoteController = TextEditingController();
  final TextEditingController _bookController = TextEditingController();
  List<Map<String, String>> _quotes = [];

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
                        onPressed: () {
                          _addQuote();
                          Navigator.pop(context);
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

  void _addQuote() {
    if (_quoteController.text.isNotEmpty && _bookController.text.isNotEmpty) {
      setState(() {
        _quotes.add({
          'quote': _quoteController.text,
          'book': _bookController.text,
        });
      });
      _quoteController.clear();
      _bookController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم نشر الاقتباس بنجاح!'),
          backgroundColor: Color(0xFF1C597B),
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
        backgroundColor: const Color(0xFF000000), // 💙 متناسق مع الخلفية
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
          Positioned(
            left: 40,
            top: 60,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 90,
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          // 📚 قائمة الاقتباسات
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
                return Card(
                  color: Colors.white.withOpacity(0.9),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    title: Text(
                      _quotes[index]['quote']!,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '📖 ${_quotes[index]['book']}',
                      style: TextStyle(color: Color(0xFF1C597B)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
