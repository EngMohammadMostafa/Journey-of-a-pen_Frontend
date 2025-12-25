import 'dart:io';
import 'package:flutter/material.dart';

class RequestBookFormPage extends StatefulWidget {
  const RequestBookFormPage({super.key});

  @override
  State<RequestBookFormPage> createState() => _RequestBookFormPageState();
}

class _RequestBookFormPageState extends State<RequestBookFormPage> {
  final _formKey = GlobalKey<FormState>();

  String title = '';
  String author = '';
  String description = '';
  String bookType = 'free';
  String price = '';
  File? file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3EDF2),
      appBar: AppBar(
        title: const Text('طلب رفع كتاب'),
        backgroundColor: const Color(0xFF1C597B),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _buildInput('عنوان الكتاب', onSaved: (v) => title = v!),
              _buildInput('اسم المؤلف', onSaved: (v) => author = v!),

              _buildInput(
                'وصف الكتاب',
                maxLines: 4,
                onSaved: (v) => description = v!,
              ),

              const SizedBox(height: 15),
              const Text('نوع الكتاب', style: TextStyle(fontWeight: FontWeight.bold)),

              Row(
                children: [
                  _radio('مجاني', 'free'),
                  _radio('مدفوع', 'paid'),
                ],
              ),

              if (bookType == 'paid')
                _buildInput(
                  'السعر',
                  keyboardType: TextInputType.number,
                  onSaved: (v) => price = v!,
                ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: const Text('إرفاق ملف الكتاب'),
                onPressed: () {
                  // مؤقت (Mock)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم اختيار ملف وهمي')),
                  );
                },
              ),

              const SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C597B),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('تم إرسال الطلب'),
                          content: const Text(
                            'تم إرسال طلب رفع الكتاب بنجاح\nالحالة: قيد المراجعة',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('حسناً'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text('إرسال الطلب'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
      String label, {
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
        required FormFieldSetter<String> onSaved,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) => v == null || v.isEmpty ? 'الحقل مطلوب' : null,
        onSaved: onSaved,
      ),
    );
  }

  Widget _radio(String text, String value) {
    return Expanded(
      child: RadioListTile(
        value: value,
        groupValue: bookType,
        title: Text(text),
        onChanged: (v) => setState(() => bookType = v!),
      ),
    );
  }
}
