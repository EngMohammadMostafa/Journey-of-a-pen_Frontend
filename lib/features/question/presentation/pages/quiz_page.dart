import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../profile/provider/profile_provider.dart';
import '../../provider/quiz_provider.dart';

class QuizPage extends StatefulWidget {
  final int bookId;
  final VoidCallback onCompleted;

  const QuizPage({
    super.key,
    required this.bookId,
    required this.onCompleted,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int? selectedOption;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<QuizProvider>().loadQuestions(widget.bookId);
    });
  }

  @override
  void dispose() {
    context.read<QuizProvider>().exitSession(widget.bookId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuizProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1C597B),
        body: Center(child: CircularProgressIndicator(color: Colors.yellow)),
      );
    }

    if (provider.errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1C597B),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Quiz', style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Text(
            provider.errorMessage!,
            style: const TextStyle(color: Colors.white, fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (provider.questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF1C597B),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Quiz', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(
          child: Text(
            "لا توجد أسئلة لهذا الكتاب",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      );
    }

    final currentQuestion = provider.currentQuestion!;
    final progress = (provider.currentIndex + 1) / provider.questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFF1C597B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () async {
                      if (provider.answeredCount > 0) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("تنبيه"),
                            content: const Text(
                                "لا يمكنك الخروج الآن.\nيجب إكمال باقي الأسئلة قبل المغادرة!"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("حسناً"),
                              )
                            ],
                          ),
                        );
                        return;
                      }
                      await provider.exitSession(widget.bookId);
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    'Quiz ${provider.currentIndex + 1}/${provider.questions.length}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "نقاطك الكلية: ${provider.totalPoints}",
                style: const TextStyle(
                    color: Colors.yellowAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  color: Colors.yellow,
                  backgroundColor: Colors.white30,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                color: Colors.white.withOpacity(0.15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    currentQuestion.question,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: currentQuestion.answers.length,
                  itemBuilder: (context, index) {
                    final answer = currentQuestion.answers[index];
                    return Card(
                      color: Colors.white
                          .withOpacity(selectedOption == index ? 0.3 : 0.15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: RadioListTile<int>(
                        value: index,
                        groupValue: selectedOption,
                        onChanged: provider.isSubmitting
                            ? null
                            : (value) => setState(() => selectedOption = value),
                        title: Text(
                          answer.answer,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                        activeColor: Colors.yellow,
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white30,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      if (provider.answeredCount > 0) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("تنبيه"),
                            content: const Text(
                                "لا يمكنك الخروج الآن.\nيجب إكمال باقي الأسئلة قبل المغادرة!"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("حسناً"),
                              )
                            ],
                          ),
                        );
                        return;
                      }
                      await provider.exitSession(widget.bookId);
                      Navigator.pop(context);
                    },
                    child: const Text('Exit', style: TextStyle(fontSize: 16)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: selectedOption == null
                        ? null
                        : () async {
                      final answer =
                      currentQuestion.answers[selectedOption!];

                      await provider.saveAnswer(
                        bookId: widget.bookId,
                        questionId: currentQuestion.id,
                        answerId: answer.id,
                        isCorrect: answer.isCorrect,
                      );

                      if (provider.currentIndex ==
                          provider.questions.length - 1) {
                        await provider.finishSession(widget.bookId);

                        // ✅ تحديث النقاط بطريقة آمنة
                        final profileProvider = Provider.of<ProfileProvider>(
                            context,
                            listen: false);
                        profileProvider.updateUserPoints(provider.totalPoints);

                        if (!mounted) return;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          showGeneralDialog(
                            context: context,
                            barrierDismissible: false,
                            barrierColor: Colors.black.withOpacity(0.4),
                            pageBuilder: (_, __, ___) => const SizedBox.shrink(),
                            transitionBuilder: (context, animation, secondaryAnimation, child) {
                              return BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                                child: ScaleTransition(
                                  scale: CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutBack,
                                  ),
                                  child: AlertDialog(
                                    backgroundColor:
                                    Colors.white.withOpacity(0.08),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(25)),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 600),
                                          curve: Curves.easeOutBack,
                                          width: 95,
                                          height: 95,
                                          decoration: BoxDecoration(
                                            color: Colors.greenAccent.withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.check_rounded,
                                              color: Colors.greenAccent, size: 55),
                                        ),
                                        const SizedBox(height: 20),
                                        const Text(
                                          "تم إنهاء الاختبار",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          "نقاطك الكلية الآن: ${provider.totalPoints}",
                                          style: const TextStyle(
                                              color: Colors.yellowAccent,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: List.generate(
                                            3,
                                                (index) => Icon(
                                              index <
                                                  ((provider.correctAnswersInSession /
                                                      provider.questions.length) *
                                                      3)
                                                      .round()
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: Colors.yellow,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 25),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.yellow,
                                            foregroundColor: Colors.black,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(18)),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 35, vertical: 12),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            widget.onCompleted();
                                            Navigator.pop(context);
                                          },
                                          child: const Text("حسناً",
                                              style: TextStyle(fontSize: 18)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        });
                      } else {
                        provider.nextQuestion();
                        setState(() => selectedOption = null);
                      }
                    },
                    child: Text(
                      provider.currentIndex == provider.questions.length - 1
                          ? 'إنهاء'
                          : 'التالي',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
