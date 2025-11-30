import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  final VoidCallback onCompleted;

  const QuizPage({super.key, required this.onCompleted});

  @override
  State<QuizPage> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizPage> {
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
