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
    {"id": "book_1", "title": "ظلال القمر", "likes_count": 120},
    {"id": "book_2", "title": "رحلة إلى المجهول", "likes_count": 95},
    {"id": "book_3", "title": "حكاية الشتاء", "likes_count": 180},
  ];

  bool _loading = true;
  Set<String> likedBooks = {};

  late AnimationController _animController;
  late Animation<double> _anim;

  bool hasJoined = false;
  int maxParticipants = 5; // الحد الأقصى للمشاركين

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _anim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    likedBooks = (prefs.getStringList('liked_books') ?? []).toSet();

    hasJoined = prefs.getBool('has_joined') ?? false; // ✅ إضافة

    books.sort((a, b) => b['likes_count'].compareTo(a['likes_count']));
    setState(() => _loading = false);
  }


  void _toggleLike(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final i = books.indexWhere((e) => e['id'] == id);
      if (likedBooks.contains(id)) {
        likedBooks.remove(id);
        books[i]['likes_count']--;
      } else {
        likedBooks.add(id);
        books[i]['likes_count']++;
      }
      books.sort((a, b) => b['likes_count'].compareTo(a['likes_count']));
    });
    prefs.setStringList('liked_books', likedBooks.toList());
  }

  void _showJoinDialog() async {
    if (books.length >= maxParticipants) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ اكتمل عدد المشاركين")),
      );
      return;
    }

    final titleController = TextEditingController();
    bool pdfSelected = false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("الانضمام للمسابقة"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "عنوان الكتاب",
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  pdfSelected = true; // محاكاة اختيار PDF
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("✔ تم اختيار ملف PDF")),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("إرفاق ملف PDF"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty || !pdfSelected) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("يرجى إدخال العنوان وإرفاق ملف PDF")),
                  );
                  return;
                }

                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('has_joined', true);

                setState(() {
                  hasJoined = true;
                  books.add({
                    "id": "user_book",
                    "title": titleController.text,
                    "likes_count": 0,
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

  Widget _bookCard(Map<String, dynamic> book, int rank) {
    final isLiked = likedBooks.contains(book['id']);

    return ScaleTransition(
      scale: _anim,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor:
              rank == 1 ? Colors.amber : const Color(0xFF1C597B),
              child: Text("$rank", style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                book['title'],
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C597B)),
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: () => _toggleLike(book['id']),
                ),
                Text("${book['likes_count']}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1C597B),
                Color(0xFF4C869F),
                Color(0xFF7199AA),
                Color(0xFFE3F2FD),
              ],
            ),
          ),
          child: SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      /// 🔹 Header بدل AppBar
                      const Text(
                        "مسابقة الكتابة",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // البطاقة الأساسية للمسابقة
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1C597B), Color(0xFF4C869F)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("المسابقة الحالية", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 6),
                            Text("اكتب قصة قصيرة مكونة من 1000 كلمة. الجوائز للمراكز الثلاثة الأولى.", style: TextStyle(color: Colors.white70)),
                            SizedBox(height: 8),
                            Text("الوقت المتبقي: 12 يوم", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.menu_book_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                "الكتب المشاركة",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.edit_note_rounded,
                              size: 20,
                            ),
                            label: const Text(
                              "الانضمام",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1C597B),
                              elevation: 4,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),

                        ],
                      ),

                      const SizedBox(height: 10),
                      ...List.generate(
                          books.length, (i) => _bookCard(books[i], i + 1)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}