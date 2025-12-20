import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WritingCompetitionsPage extends StatefulWidget {
  const WritingCompetitionsPage({super.key});

  @override
  State<WritingCompetitionsPage> createState() =>
      _WritingCompetitionsPageState();
}

class _WritingCompetitionsPageState extends State<WritingCompetitionsPage>
    with SingleTickerProviderStateMixin {

  List<Map<String, dynamic>> books = [
    {
      "id": "book_1",
      "title": "ظلال القمر",
      "likes_count": 120,
      "filePath": null,
    },
    {
      "id": "book_2",
      "title": "رحلة إلى المجهول",
      "likes_count": 95,
      "filePath": null,
    },
    {
      "id": "book_3",
      "title": "حكاية الشتاء",
      "likes_count": 180,
      "filePath": null,
    },
  ];

  bool _loading = true;
  Set<String> likedBooks = {};

  late AnimationController _animController;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _anim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _loadState();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final likedList = prefs.getStringList('liked_books') ?? [];

    setState(() {
      likedBooks = likedList.toSet();
      books.sort((a, b) =>
          (b['likes_count'] as int).compareTo(a['likes_count'] as int));
      _loading = false;
    });
  }

  Future<void> _saveLikes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('liked_books', likedBooks.toList());
  }

  void _toggleLike(String bookId) {
    setState(() {
      final index = books.indexWhere((b) => b['id'] == bookId);
      if (index == -1) return;

      if (likedBooks.contains(bookId)) {
        likedBooks.remove(bookId);
        books[index]['likes_count']--;
      } else {
        likedBooks.add(bookId);
        books[index]['likes_count']++;
      }

      books.sort((a, b) =>
          (b['likes_count'] as int).compareTo(a['likes_count'] as int));
    });

    _saveLikes();
  }

  Widget _bookCard(Map<String, dynamic> book, int rank) {
    final bool isLiked = likedBooks.contains(book['id']);

    return ScaleTransition(
      scale: _anim,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8)
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor:
              rank == 1 ? Colors.amber : const Color(0xFF1C597B),
              child: Text("$rank",
                  style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book['title'],
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C597B)),
                  ),
                ],
              ),
            ),

            // 🔹 عدد المتفاعلين + زر الإعجاب
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _toggleLike(book['id']),
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                ),
                Text(
                  "${book['likes_count']}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  // 🔹 نموذج الانضمام
  void _showJoinDialog() {
    final titleController = TextEditingController();
    final authorController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text(
            "الانضمام للمسابقة",
            style: TextStyle(
                color: Color(0xFF1C597B), fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "عنوان الكتاب",
                  prefixIcon: Icon(Icons.book),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(
                  labelText: "اسم الكاتب",
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("اختيار الملف غير مفعل حالياً")),
                  );
                },
                icon: const Icon(Icons.upload_file),
                label: const Text("رفع ملف الكتاب"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C597B),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C597B),
              ),
              onPressed: () {
                if (titleController.text.isEmpty ||
                    authorController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("يرجى تعبئة جميع الحقول")),
                  );
                  return;
                }

                setState(() {
                  books.add({
                    "id": "book_${DateTime.now().millisecondsSinceEpoch}",
                    "title": titleController.text,
                    "author": authorController.text,
                    "likes_count": 0,
                    "filePath": null,
                  });
                });

                Navigator.pop(context);
              },
              child: const Text("إرسال"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality( // 🔹 RTL عام
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFEAF6FB),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1C597B),
          title: const Text("مسابقة الكتابة"),
          centerTitle: true,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1C597B), Color(0xFF4C869F)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("المسابقة الحالية",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    SizedBox(height: 6),
                    Text("اكتب قصة قصيرة مكونة من 1000 كلمة",
                        style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 8),
                    Text("الوقت المتبقي: 12 يوم",
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Text("الكتب المشاركة",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              ...List.generate(
                  books.length, (i) => _bookCard(books[i], i + 1)),

              const SizedBox(height: 24),

              Center(
                child: ElevatedButton(
                  onPressed: _showJoinDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C597B),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    "الانضمام للمسابقة",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
