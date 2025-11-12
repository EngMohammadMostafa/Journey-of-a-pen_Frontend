import 'package:flutter/material.dart';

class PurchasedBooksSection extends StatelessWidget {
  final List<Map<String, dynamic>> books; // ✅ بيانات الكتب (اسم، صورة، حالة تحميل)

  const PurchasedBooksSection({
    Key? key,
    required this.books,
  }) : super(key: key);

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
              colors: [
                Color(0xFF1C597B),
                Color(0xFF4C869F),
                Color(0xFF7199AA),
              ],
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
                  child: books.isEmpty
                      ? const Center(
                    child: Text(
                      'لا توجد كتب مدفوعة بعد',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  )
                      : ListView.builder(
                    controller: scrollController,
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return Card(
                        color: Colors.white.withOpacity(0.15),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        child: ListTile(
                          title: Text(
                            book['title'] ?? 'كتاب بدون عنوان',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            book['author'] ?? 'مؤلف غير معروف',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: book['downloaded'] == true
                              ? const Icon(Icons.download_done, color: Colors.greenAccent)
                              : const Icon(Icons.download, color: Colors.white54),
                          onTap: () {
                            // عند النقر على الكتاب يمكنك فتحه مثلاً
                          },
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
}
