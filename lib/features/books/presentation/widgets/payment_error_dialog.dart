import 'package:flutter/material.dart';

class PaymentErrorDialog extends StatelessWidget {
  const PaymentErrorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("❌ خطأ في الدفع"),
      content: const Text("رصيدك غير كافٍ لإتمام عملية الشراء."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("إغلاق"),
        ),
      ],
    );
  }
}
