import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('طلب نشر كتاب'),
          backgroundColor: const Color(0xFF1C597B),
          elevation: 0,
        ),
        body: Stack(
          children: [
            // الخلفية المتدرجة
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1C597B),
                    Color(0xFF4C869F),
                    Color(0xFF7199AA),
                    Color(0xFFE3F2FD),
                  ],
                ),
              ),
            ),
            // محتوى الصفحة
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    _buildCardField(
                      child: _buildInput('عنوان الكتاب', onSaved: (v) => title = v!),
                    ),

                    _buildCardField(
                      child: _buildInput('اسم المؤلف', onSaved: (v) => author = v!),
                    ),

                    _buildCardField(
                      child: _buildInput(
                        'وصف الكتاب',
                        maxLines: 5,
                        onSaved: (v) => description = v!,
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'نوع الكتاب',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _radio('مجاني', 'free'),
                        _radio('مدفوع', 'paid'),
                      ],
                    ),

                    // حقل السعر مع Animation عند الاختيار
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) {
                        return FadeTransition(
                          opacity: anim,
                          child: SizeTransition(
                            sizeFactor: anim,
                            axisAlignment: -1.0,
                            child: child,
                          ),
                        );
                      },
                      child: bookType == 'paid'
                          ? _buildCardField(
                        key: const ValueKey('price_field'),
                        child: _buildInput(
                          'السعر',
                          keyboardType: TextInputType.number,
                          onSaved: (v) => price = v!,
                        ),
                      )
                          : const SizedBox.shrink(
                        key: ValueKey('empty'),
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildCardField(
                      child: _interactiveButton(
                        icon: Icons.attach_file,
                        text: 'إرفاق ملف الكتاب (PDF فقط)',
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf'],
                          );
                          if (result != null && result.files.single.path != null) {
                            setState(() {
                              file = File(result.files.single.path!);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('تم اختيار الملف: ${result.files.single.name}')),
                            );
                          }
                        },
                      ),
                    ),

                    if (file != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _buildCardField(
                          child: Row(
                            children: [
                              const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  file!.path.split('/').last,
                                  style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 30),

                    Center(
                      child: _interactiveButton(
                        text: 'إرسال الطلب',
                        icon: Icons.send,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (file == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('يرجى إرفاق ملف PDF')),
                              );
                              return;
                            }
                            _formKey.currentState!.save();
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: const Text('تم إرسال الطلب'),
                                content: Text(
                                  'تم إرسال طلب رفع الكتاب بنجاح\n'
                                      'العنوان: $title\n'
                                      'المؤلف: $author\n'
                                      'الحالة: قيد المراجعة',
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// كارت بحواف دائرية، ظل، وإطار خفيف
  Widget _buildCardField({required Widget child, Key? key}) {
    return GestureDetector(
      onTapDown: (_) => setState(() {}),
      onTapUp: (_) => setState(() {}),
      child: AnimatedContainer(
        key: key,
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF4C869F),
              Color(0xFF7199AA),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.4), // الإطار الخارجي
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _buildInput(
      String label, {
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
        required FormFieldSetter<String> onSaved,
      }) {
    return TextFormField(
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        border: InputBorder.none,
      ),
      validator: (v) => v == null || v.isEmpty ? 'الحقل مطلوب' : null,
      onSaved: onSaved,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
    );
  }

  Widget _radio(String text, String value) {
    return Expanded(
      child: RadioListTile(
        value: value,
        groupValue: bookType,
        title: Text(text, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
        activeColor: const Color(0xFF1C597B),
        contentPadding: EdgeInsets.zero,
        onChanged: (v) => setState(() => bookType = v!),
      ),
    );
  }

  Widget _interactiveButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      splashColor: Colors.white24,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1C597B),
              Color(0xFF4C869F),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
