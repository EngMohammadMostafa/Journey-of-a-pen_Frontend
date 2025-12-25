import 'package:flutter/material.dart';

class MyRequestsPage extends StatelessWidget {
  const MyRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // بيانات وهمية
    final requests = [
      {
        'title': 'رحلة في عالم Flutter',
        'status': 'pending',
      },
      {
        'title': 'أساسيات البرمجة',
        'status': 'accepted',
      },
      {
        'title': 'الذكاء الاصطناعي للمبتدئين',
        'status': 'rejected',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE3EDF2),
      appBar: AppBar(
        title: const Text('طلباتي'),
        backgroundColor: const Color(0xFF1C597B),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (_, i) {
          final r = requests[i];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              title: Text(r['title'] as String),
              trailing: _statusChip(r['status'] as String),
            ),
          );
        },
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'accepted':
        color = Colors.green;
        text = 'مقبول';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'مرفوض';
        break;
      default:
        color = Colors.orange;
        text = 'قيد المراجعة';
    }

    return Chip(
      label: Text(text, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }
}
