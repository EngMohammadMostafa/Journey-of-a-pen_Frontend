import 'package:flutter/material.dart';
import '../../../../core/api/api_service.dart';
import '../widgets/competition_book_card.dart';

class WritingCompetitionsPage extends StatefulWidget {
  const WritingCompetitionsPage({super.key});

  @override
  State<WritingCompetitionsPage> createState() => _WritingCompetitionsPageState();
}

class _WritingCompetitionsPageState extends State<WritingCompetitionsPage> {
  Map<String, dynamic>? competition;
  List<Map<String, dynamic>> books = [];
  bool _loading = true;
  Set<int> likedBooks = {};
  bool hasJoined = false;

  final api = ApiService();

  @override
  void initState() {
    super.initState();
    _loadCompetitionData();
  }

  Future<void> _loadCompetitionData() async {
    try {
      // جلب بيانات المسابقة الحالية
      final compResp = await api.get('/competitions');
      final compData = compResp.data;

      if ((compData['competitions'] as List).isEmpty) {
        // لا توجد مسابقات
        setState(() {
          _loading = false;
          competition = null;
        });
        return;
      }

      competition = compData['competitions'][0];

      // جلب كتب المسابقة
      final booksResp = await api.get('/competitions/${competition!['id']}/books');
      final booksData = booksResp.data;

      books = List<Map<String, dynamic>>.from(booksData['books']);

      // التحقق إذا كان المستخدم قد انضم مسبقاً
      hasJoined = books.any((b) => b['user_id'] == 1); // عدّل 1 إلى id المستخدم الفعلي

      // مجموعة الكتب المعجب بها من قبل المستخدم
      likedBooks = {};
    } catch (e) {
      print("Error loading competition: $e");
    }

    setState(() => _loading = false);
  }

  Future<void> _toggleLike(int bookId) async {
    try {
      final response =
      await api.post('/competition-books/$bookId/like');

      final data = response.data;

      setState(() {
        final index = books.indexWhere(
                (b) => b['competition_book_id'] == bookId);

        if (index == -1) return;

        books[index]['likes_count'] = data['likes_count'];

        if (data['liked']) {
          likedBooks.add(bookId);
        } else {
          likedBooks.remove(bookId);
        }

        //  ترتيب مباشر
        books.sort(
              (a, b) => (b['likes_count'] ?? 0)
              .compareTo(a['likes_count'] ?? 0),
        );
      });


    } catch (e) {
      print("Error toggling like: $e");
    }
  }


  void _showJoinDialog() {
    if (books.length >= (competition?['max_user'] ?? 5)) {
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
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "الانضمام للمسابقة",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1C597B)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "عنوان الكتاب",
                    labelStyle: const TextStyle(color: Color(0xFF1C597B)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    pdfSelected = true;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("✔ تم اختيار ملف PDF")),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("إرفاق ملف PDF"),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1C597B)),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "إلغاء",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1C597B)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (titleController.text.isEmpty || !pdfSelected) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("يرجى إدخال العنوان وإرفاق ملف PDF")),
                            );
                            return;
                          }

                          // رفع الكتاب باستخدام Multipart POST عبر ApiService
                          // final file = MultipartFile.fromFile(filePath, filename: 'file.pdf');
                          // await api.post('/competitions/${competition!['id']}/books', data: {'title': titleController.text, 'file': file});

                          setState(() => hasJoined = true);
                          Navigator.pop(context);
                        },
                        child: const Text("إرسال"),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1C597B)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            // الخلفية الثابتة
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1C597B), Color(0xFF4C869F), Color(0xFF7199AA), Color(0xFFE3F2FD)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            SafeArea(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "مسابقة الكتابة",
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 20),

                      // إذا لم توجد مسابقات
                      if (competition == null)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            "لا توجد مسابقات حالياً",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                      // عرض بيانات المسابقة
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF1C597B), Color(0xFF4C869F)]),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                competition!['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                competition!['description'] ?? "الجوائز للمراكز الثلاثة الأولى",
                                style: const TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "وقت الانتهاء: ${competition!['enddate'] ?? 'غير معروف'}",
                                style: const TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.menu_book_rounded, color: Colors.white, size: 22),
                              SizedBox(width: 6),
                              Text(
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
                          ElevatedButton.icon(
                            onPressed: hasJoined || competition == null ? null : _showJoinDialog,
                            icon: const Icon(Icons.edit_note_rounded, size: 20),
                            label: const Text("الانضمام", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1C597B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // عرض الكتب المشاركة
                      if (books.isEmpty && competition != null)
                        const Text(
                          "لا توجد كتب مشاركة حتى الآن",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        )
                      else
                        ...books.map(
                              (b) => CompetitionBookCard(
                            rank: books.indexOf(b) + 1,
                            title: b['title'],
                                likesCount: (b['likes_count'] ?? 0),
                                isLiked: likedBooks.contains(b['competition_book_id']),
                                imagePath: "assets/images/book_placeholder.png",
                            onLikeToggle: () => _toggleLike(b['competition_book_id']),
                            onRead: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => BookReaderPage(title: b['title'])),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookReaderPage extends StatelessWidget {
  final String title;

  const BookReaderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: const Color(0xFF1C597B)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1C597B))),
              const SizedBox(height: 12),
              const Text("هنا يتم عرض محتوى الكتاب بصيغة احترافية...", style: TextStyle(fontSize: 18, height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }
}
