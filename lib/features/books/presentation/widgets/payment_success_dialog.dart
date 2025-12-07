import 'package:flutter/material.dart';

class PaymentSuccessDialog extends StatelessWidget {
  const PaymentSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(" تمت العملية بنجاح"),
      content: const Text("تم شراء الكتاب وإضافته إلى سلة المشتريات."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("حسنًا"),
        ),
      ],
    );
  }
}
