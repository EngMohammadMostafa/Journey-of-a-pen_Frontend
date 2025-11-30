import 'package:flutter/material.dart';
import '../../../books/data/models/book_model.dart';

class PurchasedBooksSection extends StatefulWidget {
  final List<BookModel> books;
  final void Function(BookModel)? onBookTap;

  const PurchasedBooksSection({
    super.key,
    required this.books,
    this.onBookTap,
  });
  @override
  State<PurchasedBooksSection> createState() => _PurchasedBooksSectionState();
}

class _PurchasedBooksSectionState extends State<PurchasedBooksSection> {
  // تخزين حالة كل كتاب: هل أنهى الأسئلة أم لا
  Map<int, bool> quizCompleted = {};

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1C597B), Color(0xFF4C869F), Color(0xFF7199AA)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '📚 الكتب المدفوعة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: widget.books.length,
                itemBuilder: (context, index) {
                  final book = widget.books[index]; // تعريف book هنا داخل itemBuilder

                  return Card(
                    color: Colors.white.withOpacity(0.15),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: ListTile(
                      title: Text(
                        book.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        book.author,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      onTap: () {
                        if (widget.onBookTap != null) {
                          widget.onBookTap!(book); // عند النقر على الكتاب
                        }
                      },
                      trailing: quizCompleted[index] == true
                          ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                          : ElevatedButton(
                        onPressed: () {
                          if (quizCompleted[index] == true) return;
                          _openQuiz(context, index); // index موجود داخل itemBuilder
                        },
                        child: const Text('Quiz'),
                      ),
                    ),
                  );
                },
              ),
            ),
                
              ],
            ),
          ),
        );
      },
    );
  }

  void _openQuiz(BuildContext context, int bookIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          onCompleted: () {
            setState(() => quizCompleted[bookIndex] = true);
          },
        ),
      ),
    );
  }
}

// ---------------- QUIZ SCREEN -----------------

class QuizScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  const QuizScreen({super.key, required this.onCompleted});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestion = 0;
  int score = 0;
  bool answered = false;
  int? selectedOption;

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'ما هو الموضوع الرئيسي للكتاب؟',
      'options': ['الخيار A', 'الخيار B', 'الخيار C'],
      'correct': 1
    },
    {
      'question': 'من هو البطل في القصة؟',
      'options': ['الخيار A', 'الخيار B', 'الخيار C'],
      'correct': 0
    },
    {
      'question': 'ماذا تعلّم القارئ من الكتاب؟',
      'options': ['الخيار A', 'الخيار B', 'الخيار C'],
      'correct': 2
    },
  ];

  @override
  Widget build(BuildContext context) {
    final q = questions[currentQuestion];

    return Scaffold(
      backgroundColor: const Color(0xFF1C597B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Quiz'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              q['question'],
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...List.generate(q['options'].length, (i) {
              return RadioListTile<int>(
                value: i,
                groupValue: selectedOption,
                onChanged: answered ? null : (value) {
                  setState(() => selectedOption = value);
                },
                title: Text(q['options'][i], style: const TextStyle(color: Colors.white)),
              );
            }),
            const SizedBox(height: 20),
            if (!answered)
              ElevatedButton(
                onPressed: selectedOption == null ? null : _checkAnswer,
                child: const Text('تحقق'),
              ),
            if (answered)
              Text(
                selectedOption == q['correct'] ? '✔ إجابة صحيحة' : '✘ إجابة خاطئة',
                style: const TextStyle(fontSize: 20, color: Colors.yellow),
              ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: answered ? null : () => Navigator.pop(context),
                  child: const Text('Exit'),
                ),
                ElevatedButton(
                  onPressed: answered ? _next : null,
                  child: const Text('التالي'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _checkAnswer() {
    final correct = questions[currentQuestion]['correct'];
    if (selectedOption == correct) score++;
    setState(() => answered = true);
  }

  void _next() {
    if (currentQuestion == questions.length - 1) {
      widget.onCompleted();
      Navigator.pop(context);
      return;
    }
    setState(() {
      currentQuestion++;
      answered = false;
      selectedOption = null;
    });
  }
}
