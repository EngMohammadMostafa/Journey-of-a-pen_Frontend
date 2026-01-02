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
  void _showCompetitionRules() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1C597B),
                  Color(0xFF4C869F),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: const [
                    Icon(Icons.info_outline, color: Colors.white, size: 30),
                    SizedBox(width: 10),
                    Text(
                      "شروط الاشتراك",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Text(
                  "• المشاركة متاحة مرة واحدة فقط لكل مستخدم\n"
                      "• يجب رفع الكتاب بصيغة PDF\n"
                      "• الحد الأقصى لحجم الملف 10 ميغابايت\n"
                      "• يتم عرض الكتاب بعد موافقة الإدارة\n"
                      "• عدد المشاركين محدود",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1C597B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "حسناً",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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

      //جلب كل الكتب التي تمت الموافقة عليها
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
      _showErrorDialog(" لم يتم تسجيل الدخول");
      return;
    }

    if (books.length >= (competition?['max_user'] ?? 5)) {
      _showErrorDialog(" اكتمل عدد المشاركين");
      return;
    }

    final titleController = TextEditingController();
    File? selectedPdf;

    bool titleEmpty = false;
    bool fileEmpty = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
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
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C597B),
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (hasJoined)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          " لقد شاركت مسبقًا في هذه المسابقة",
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: "عنوان الكتاب",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: titleEmpty ? Colors.red : Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: titleEmpty ? Colors.red : Colors.blue),
                        ),
                      ),
                      enabled: !hasJoined,
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: Text(selectedPdf != null
                          ? selectedPdf!.path.split('/').last
                          : "اختيار ملف PDF"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: fileEmpty
                            ? Colors.red.shade400
                            : const Color(0xFF1C597B),
                      ),
                      onPressed: hasJoined
                          ? null
                          : () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf'],
                        );

                        if (result != null &&
                            result.files.isNotEmpty &&
                            result.files.single.path != null) {
                          setStateDialog(() {
                            selectedPdf = File(result.files.single.path!);
                            fileEmpty = false;
                          });
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
                            onPressed: hasJoined
                                ? null
                                : () async {
                              setStateDialog(() {
                                titleEmpty = titleController.text.isEmpty;
                                fileEmpty = selectedPdf == null;
                              });

                              if (titleEmpty || fileEmpty) {
                                _showErrorDialog("يرجى تعبئة جميع الحقول المطلوبة");
                                return;
                              }

                              try {
                                final formData = FormData.fromMap({
                                  'title': titleController.text,
                                  'file': await MultipartFile.fromFile(
                                    selectedPdf!.path,
                                    filename: selectedPdf!.path.split('/').last,
                                  ),
                                });

                                await api.dio.post(
                                  ApiEndpoints.participateInCompetition(competition!['id']),
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

                                _showSuccessDialog(
                                    "تم إرسال الكتاب للمراجعة بانتظار موافقة الإدارة.\nسيتم عرض الكتاب على الصفحة بمجرد الموافقة."
                                );

                              } on DioException catch (e) {
                                String errorMsg = "فشل رفع الكتاب";

                                if (e.response?.data != null) {
                                  if (e.response?.data['message'] != null) {
                                    errorMsg = e.response!.data['message'];
                                  }
                                  if (e.response?.data['errors'] != null) {
                                    final errors = e.response!.data['errors'] as Map;
                                    errors.forEach((key, value) {
                                      errorMsg += "\n• ${value.join(', ')}";
                                    });
                                  }
                                }

                                _showErrorDialog(errorMsg);
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
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1C597B), Color(0xFF4C869F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.white, size: 36),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "نجاح",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1C597B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("حسناً", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1C597B), Color(0xFF4C869F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: const [
                    Icon(Icons.error, color: Colors.red, size: 36),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "خطأ",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1C597B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("حسناً", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                        Row(
                          children: [
                            //  أيقونة شروط المسابقة
                            InkWell(
                              onTap: _showCompetitionRules,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.info_outline,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            //  زر الانضمام
                            ElevatedButton.icon(
                              onPressed: (!_loading && competition != null && !hasJoined)
                                  ? _showJoinDialog
                                  : hasJoined
                                  ? () {
                                _showErrorDialog("لقد شاركت مسبقًا في هذه المسابقة");
                              }
                                  : null,
                              icon: const Icon(Icons.edit_note_rounded, size: 20),
                              label: const Text(
                                "الانضمام",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: (!_loading && !hasJoined && competition != null)
                                    ? const Color(0xFF1C597B)
                                    : Colors.grey.shade400,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
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
