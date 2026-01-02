import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color? textColor;
  final bool isLoading;
  final bool isSecondary;

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.color,
    this.textColor,
    this.isLoading = false,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSecondary ? Colors.transparent : color;
    final effectiveTextColor = textColor ?? (isSecondary ? color : Colors.white);
    final border = isSecondary
        ? BorderSide(color: color, width: 2)
        : BorderSide.none;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: border,
          ),
          elevation: isSecondary ? 0 : 2,
        ),
        child: isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : Text(
          text,
          style: TextStyle(
            color: effectiveTextColor,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
