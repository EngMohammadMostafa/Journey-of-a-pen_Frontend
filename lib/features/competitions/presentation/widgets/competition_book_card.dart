import 'package:flutter/material.dart';

class CompetitionBookCard extends StatelessWidget {
  final int rank;
  final String title;
  final int likesCount;
  final bool isLiked;
  final VoidCallback onLikeToggle;
  final VoidCallback onRead;
  final String imagePath;

  const CompetitionBookCard({
    super.key,
    required this.rank,
    required this.title,
    required this.likesCount,
    required this.isLiked,
    required this.onLikeToggle,
    required this.onRead,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    bool _isPressed = false; // لا يمكن تغييره في StatelessWidget فعليًا

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // اليسار: الرتبة والعنوان + التفاعلات داخل إطار
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الرتبة والعنوان
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor:
                      rank == 1 ? Colors.amber : const Color(0xFF1C597B),
                      child: Text(
                        "$rank",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C597B)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // صندوق التفاعلات أسفل العنوان
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.grey,
                        ),
                        onPressed: onLikeToggle,
                        iconSize: 25,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 6),
                      Text("$likesCount",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.download_rounded,
                            color: Color(0xFF1C597B)),
                        tooltip: "قراءة الكتاب",
                        onPressed: onRead,
                        iconSize: 25,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // اليمين: صورة افتراضية للكتاب
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              width: 80,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
