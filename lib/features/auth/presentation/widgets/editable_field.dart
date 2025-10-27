import 'package:flutter/material.dart';

class EditableField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool enabled;

  const EditableField({
    super.key,
    required this.controller,
    required this.label,
    this.enabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}
