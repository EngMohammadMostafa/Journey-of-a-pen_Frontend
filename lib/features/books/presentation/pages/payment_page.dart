import 'package:flutter/material.dart';
import '../../data/models/book_model.dart';
import '../widgets/payment_success_dialog.dart';
import '../widgets/payment_error_dialog.dart';

class PaymentPage extends StatefulWidget {
  final BookModel book;
  const PaymentPage({super.key, required this.book});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  double balance = 20.0; // رصيد المستخدم الافتراضي
  double bookPrice = 9.99;

  void _processPayment() {
    if (balance >= bookPrice) {
      setState(() => balance -= bookPrice);
      showDialog(
        context: context,
        builder: (_) => const PaymentSuccessDialog(),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => const PaymentErrorDialog(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    return Scaffold(
      appBar: AppBar(
        title: const Text("إتمام عملية الدفع"),
        backgroundColor: const Color(0xFF1C597B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "الكتاب: ${book.title}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("السعر: \$${bookPrice.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 16, color: Colors.red)),
            const SizedBox(height: 10),
            Text("رصيدك الحالي: \$${balance.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 16, color: Colors.green)),
            const SizedBox(height: 30),

            Center(
              child: ElevatedButton.icon(
                onPressed: _processPayment,
                icon: const Icon(Icons.payment),
                label: const Text("دفع الآن"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
