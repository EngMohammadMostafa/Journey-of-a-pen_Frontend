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
  // ----- بيانات مبدئية (يمكن استبدالها ببيانات من API لاحقًا) -----
  List<Map<String, dynamic>> books = [
    {
      "id": "book_1",
      "title": "ظلال القمر",
      "author": "سارة أحمد",
      "votes": 120,
      "filePath": null,
    },
    {
      "id": "book_2",
      "title": "رحلة إلى المجهول",
      "author": "خالد محمد",
      "votes": 95,
      "filePath": null,
    },
    {
      "id": "book_3",
      "title": "حكاية الشتاء",
      "author": "ليان يوسف",
      "votes": 180,
      "filePath": null,
    }
  ];

  bool _loading = true;
  int totalVotes = 1;

  // لإدارة حالة التصويت المحلي (مرة واحدة)
  bool hasVoted = false;
  String? votedBookId;

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
    // حساب مجموع الأصوات محليًا + استرجاع حالة التصويت من SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      hasVoted = prefs.getBool('competition_has_voted') ?? false;
      votedBookId = prefs.getString('competition_voted_book_id');
      totalVotes = books.fold(0, (s, b) => s + (b['votes'] as int));
      if (totalVotes == 0) totalVotes = 1; // لحماية القسمة على صفر
      books.sort((a, b) => (b['votes'] as int).compareTo(a['votes'] as int));
      _loading = false;
    });
  }

  Future<void> _persistVote(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('competition_has_voted', true);
    await prefs.setString('competition_voted_book_id', bookId);
  }

  void _vote(String bookId) {
    if (hasVoted) {
      // مستخدم قد صوّت مسبقًا
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لقد صوتت بالفعل في هذه المسابقة.")),
      );
      return;
    }

    setState(() {
      final idx = books.indexWhere((b) => b['id'] == bookId);
      if (idx != -1) {
        books[idx]['votes'] = (books[idx]['votes'] as int) + 1;
        totalVotes++;
        hasVoted = true;
        votedBookId = bookId;
        // إعادة ترتيب الكتب حسب التصويت
        books.sort((a, b) => (b['votes'] as int).compareTo(a['votes'] as int));
      }
    });

    _persistVote(bookId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم تسجيل صوتك — شكرًا لمشاركتك!")),
    );
  }

  // إضافة مشاركة جديدة من المستخدم (مع رفع ملف)
  Future<void> _showJoinDialog() async {
    TextEditingController titleController = TextEditingController();
    TextEditingController authorController = TextEditingController();
    String? pickedPath;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("المشاركة في المسابقة", style: TextStyle(color: Color(0xFF1C597B))),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: "عنوان الكتاب"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: authorController,
                    decoration: const InputDecoration(labelText: "اسم المؤلف"),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.upload_file),
                        label: const Text("اختر ملف PDF"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C597B),
                        ),
                        onPressed: () async {
                          try {

                          } catch (e) {
                            // خطأ باختيار الملف
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("فشل اختيار الملف: $e")),
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          pickedPath == null ? "لم يتم اختيار ملف" : (pickedPath!.split('/').last),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1C597B)),
                onPressed: () {
                  final title = titleController.text.trim();
                  final author = authorController.text.trim();
                  if (title.isEmpty || author.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("الرجاء تعبئة العنوان والمؤلف")),
                    );
                    return;
                  }
                  // إضافة الكتاب محليًا
                  setState(() {
                    final newBook = {
                      "id": "book_${DateTime.now().millisecondsSinceEpoch}",
                      "title": title,
                      "author": author,
                      "votes": 0,
                      "filePath": pickedPath,
                    };
                    books.add(newBook);
                    // تحديث المجموع
                    totalVotes = books.fold(0, (s, b) => s + (b['votes'] as int));
                    if (totalVotes == 0) totalVotes = 1;
                    books.sort((a, b) => (b['votes'] as int).compareTo(a['votes'] as int));
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("تم إضافة المشاركة بنجاح!")),
                  );
                },
                child: const Text("إرسال"),
              ),
            ],
          );
        });
      },
    );
  }

  // تصميم البطاقة لكل كتاب
  Widget _bookCard(Map<String, dynamic> book, int rank) {
    final int votes = book['votes'] as int;
    final double percent = votes / totalVotes;
    final bool isVotedBook = (votedBookId != null && votedBookId == book['id']);

    return ScaleTransition(
      scale: _anim,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: rank, title, author
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: rank == 1 ? Colors.amber[700] : const Color(0xFF1C597B),
                  child: Text(
                    "$rank",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1C597B))),
                      const SizedBox(height: 4),
                      Text("بواسطة ${book['author']}", style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
                // Votes count badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isVotedBook ? Colors.green[50] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.how_to_vote, size: 16, color: Colors.black54),
                      const SizedBox(width: 6),
                      Text("$votes"),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress bar with percent
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 10,
                    backgroundColor: Colors.grey[200],
                    color: const Color(0xFF1C597B),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${(percent * 100).toStringAsFixed(1)}%", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        if (book['filePath'] != null)
                          IconButton(
                            onPressed: () {
                              // يمكنك هنا فتح الملف باستخدام advance_pdf_viewer2 أو أي طريقة تناسبك
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("فتح الملف (لم يُدمج هنا)")),
                              );
                            },
                            icon: const Icon(Icons.picture_as_pdf, color: Color(0xFF1C597B)),
                          ),
                        const SizedBox(width: 6),
                        ElevatedButton.icon(
                          onPressed: hasVoted ? null : () => _vote(book['id'] as String),
                          icon: const Icon(Icons.how_to_vote, size: 18),
                          label: Text(hasVoted ? (isVotedBook ? "صوتت هنا" : "غير متاح") : "صوّت"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isVotedBook ? Colors.green : const Color(0xFF1C597B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------- الواجهة ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C597B),
        title: const Text("مسابقة الكتابة الشهرية"),
        centerTitle: true,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () async {
          // إعادة تحميل/تحديث (مكان جيد لربط API لاحقًا)
          await _loadState();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

              const SizedBox(height: 18),

              // رأس قائمة الكتب
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("الكتب المشاركة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C597B))),
                  Row(
                    children: [
                      Text("إجمالي الأصوات: $totalVotes", style: const TextStyle(color: Colors.black54)),
                      const SizedBox(width: 12),
                      hasVoted
                          ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12)),
                        child: Row(children: const [Icon(Icons.check, size: 16, color: Colors.green), SizedBox(width: 6), Text("لقد صوتت", style: TextStyle(color: Colors.green))]),
                      )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // قائمة الكتب
              Column(
                children: List.generate(books.length, (i) => _bookCard(books[i], i + 1)),
              ),

              const SizedBox(height: 24),
              // زر الانضمام (ثابت أسفل)
              Center(
                child: ElevatedButton(
                  onPressed: _showJoinDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C597B),
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text("الانضمام للمسابقة", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
