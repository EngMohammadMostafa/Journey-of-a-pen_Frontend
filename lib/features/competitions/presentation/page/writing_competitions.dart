import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_service.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../widgets/competition_book_card.dart';
import '../widgets/competition_card.dart';
import 'competition_book_reader_page.dart';

class WritingCompetitionsPage extends StatefulWidget {
  const WritingCompetitionsPage({super.key});

  @override
  State<WritingCompetitionsPage> createState() =>
      _WritingCompetitionsPageState();
}

class _WritingCompetitionsPageState extends State<WritingCompetitionsPage> {
  Map<String, dynamic>? competition;
  List<Map<String, dynamic>> books = [];
  bool _loading = true;
  bool hasJoined = false;
  Set<int> likedBooks = {};
  final api = ApiService();

  @override
  void initState() {
    super.initState();
    _loadCompetitionData();
  }

  Future<void> _loadCompetitionData() async {
    try {
      final compResp = await api.get('/competitions');
      final compData = compResp.data;

      if ((compData['competitions'] as List).isEmpty) {
        setState(() {
          _loading = false;
          competition = null;
        });
        return;
      }

      competition = compData['competitions'][0];

      final booksResp =
      await api.get('/competitions/${competition!['id']}/books');

      // جلب كل الكتب التي أرسلها السيرفر (تمت الموافقة عليها مسبقًا من الباك)
      books = List<Map<String, dynamic>>.from(booksResp.data['books']);

      // معرفة إذا كان المستخدم قد شارك مسبقًا
      hasJoined = booksResp.data['user_has_joined'] ?? false;

      likedBooks.clear();
    } catch (e) {
      debugPrint("Error loading competition: $e");
    }

    setState(() => _loading = false);
  }

  Future<void> _toggleLike(Map<String, dynamic> book) async {
    final bookId = book['competition_book_id'];
    try {
      final response = await api.post('/competition-books/$bookId/like');
      final data = response.data;

      setState(() {
        final index = books.indexWhere((b) => b['competition_book_id'] == bookId);
        if (index == -1) return;

        books[index]['likes_count'] = data['likes_count'];

        if (data['liked'] == true) {
          likedBooks.add(bookId);
        } else {
          likedBooks.remove(bookId);
        }

        // ترتيب مباشر حسب اللايكات
        books.sort((a, b) =>
            (b['likes_count'] ?? 0).compareTo(a['likes_count'] ?? 0));
      });
    } catch (e) {
      debugPrint("Error toggling like: $e");
    }
  }

  void _showJoinDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ لم يتم تسجيل الدخول")),
      );
      return;
    }

    if (books.length >= (competition?['max_user'] ?? 5)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ اكتمل عدد المشاركين")),
      );
      return;
    }

    final titleController = TextEditingController();
    File? selectedPdf;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "الانضمام للمسابقة",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C597B),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "عنوان الكتاب",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("اختيار ملف PDF"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C597B),
                  ),
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf'],
                    );

                    if (result?.files.single.path != null) {
                      selectedPdf = File(result!.files.single.path!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("✔ تم اختيار ملف PDF")),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("إلغاء"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C597B),
                        ),
                        child: const Text("إرسال"),
                        onPressed: () async {
                          if (titleController.text.isEmpty ||
                              selectedPdf == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "يرجى إدخال العنوان وإرفاق ملف PDF"),
                              ),
                            );
                            return;
                          }

                          try {
                            final formData = FormData.fromMap({
                              'title': titleController.text,
                              'file': await MultipartFile.fromFile(
                                selectedPdf!.path,
                                filename:
                                selectedPdf!.path.split('/').last,
                              ),
                            });

                            await api.dio.post(
                              ApiEndpoints.participateInCompetition(
                                  competition!['id']),
                              data: formData,
                              options: Options(
                                headers: {
                                  'Authorization': 'Bearer $token',
                                  'Content-Type': 'multipart/form-data',
                                },
                              ),
                            );

                            await _loadCompetitionData();
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                  Text("✔ تم رفع الكتاب بنجاح")),
                            );
                          } on DioException catch (e) {
                            if (e.response?.statusCode == 409) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.response?.data['message'] ??
                                        "أنت مشارك مسبقًا",
                                  ),
                                ),
                              );
                            } else if (e.response?.statusCode == 403) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.response?.data['message'] ??
                                        "المسابقة غير متاحة",
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("فشل رفع الكتاب")),
                              );
                            }
                          }
                        },
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
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1C597B),
                    Color(0xFF4C869F),
                    Color(0xFF7199AA),
                    Color(0xFFE3F2FD)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            SafeArea(
              child: _loading
                  ? const Center(
                child:
                CircularProgressIndicator(color: Colors.white),
              )
                  : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "مسابقة الكتابة",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // كرت المسابقة العلوي
                    if (competition != null)
                      CompetitionCard(
                        name: competition!['name'] ?? "المسابقة",
                        description: competition!['description'],
                        endDate: competition!['enddate'] ?? 'غير معروف',
                      ),
                    const SizedBox(height: 20),

                    // قسم الكتب
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.menu_book_rounded,
                                color: Colors.white, size: 22),
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
                          onPressed: (!_loading &&
                              !hasJoined &&
                              competition != null)
                              ? _showJoinDialog
                              : null,
                          icon: const Icon(Icons.edit_note_rounded,
                              size: 20),
                          label: const Text(
                            "الانضمام",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (!_loading &&
                                !hasJoined &&
                                competition != null)
                                ? const Color(0xFF1C597B)
                                : Colors.grey.shade400,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // عرض الكتب الموافق عليها
                    if (books.isEmpty)
                      const Text(
                        "لا توجد كتب مشاركة حتى الآن",
                        style: TextStyle(
                            color: Colors.white70, fontSize: 16),
                      )
                    else
                      ...books.map(
                            (b) => CompetitionBookCard(
                          rank: books.indexOf(b) + 1,
                          title: b['title'],
                          likesCount: b['likes_count'] ?? 0,
                          isLiked: likedBooks.contains(
                              b['competition_book_id']),
                          imagePath:
                          "assets/images/book_placeholder.png",
                          competitionBookId:
                          b['competition_book_id'],
                          onLikeToggle: () =>
                              _toggleLike(b),
                              onRead: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CompetitionBookReaderPage(
                                      bookId: b['competition_book_id'],
                                      title: b['title'],
                                    ),
                                  ),
                                );
                              },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
