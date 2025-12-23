import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_service.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../data/pdf_service.dart';
import '../page/competition_book_reader_page.dart'; // إذا لازلت تستخدم PdfService لقراءة الكتب

class CompetitionBookCard extends StatefulWidget {
  final int rank;
  final String title;
  final int likesCount;
  final bool isLiked;
  final VoidCallback onLikeToggle;
  final VoidCallback onRead;
  final String imagePath;
  final int competitionBookId; // المعرف الحقيقي للكتاب
  final ScrollController? scrollController;

  const CompetitionBookCard({
    super.key,
    required this.rank,
    required this.title,
    required this.likesCount,
    required this.isLiked,
    required this.onLikeToggle,
    required this.onRead,
    required this.imagePath,
    required this.competitionBookId,
    this.scrollController,
  });

  @override
  State<CompetitionBookCard> createState() => _CompetitionBookCardState();
}

class _CompetitionBookCardState extends State<CompetitionBookCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.4)
        .chain(CurveTween(curve: Curves.easeOutBack))
        .animate(_controller);

    _shakeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant CompetitionBookCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isLiked && widget.isLiked) {
      _controller.forward(from: 0);

      if (widget.scrollController != null) {
        widget.scrollController!.animateTo(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBadge(int rank) {
    switch (rank) {
      case 1:
        return const Text('🥇', style: TextStyle(fontSize: 24));
      case 2:
        return const Text('🥈', style: TextStyle(fontSize: 22));
      case 3:
        return const Text('🥉', style: TextStyle(fontSize: 20));
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: Container(
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
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: widget.rank == 1
                                ? const Color(0xFF1C597B)
                                : const Color(0xFF4C869F),
                            child: Text(
                              "${widget.rank}",
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Positioned(
                            top: -4,
                            right: -4,
                            child: _buildBadge(widget.rank),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C597B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: IconButton(
                            icon: Icon(
                              widget.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: widget.isLiked ? Colors.red : Colors.grey,
                            ),
                            onPressed: widget.onLikeToggle,
                            iconSize: 24,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "${widget.likesCount}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 16),
                        // زر التحميل الجديد
                        IconButton(
                          icon: const Icon(Icons.download_rounded, color: Color(0xFF1C597B)),
                          onPressed: () async {
                            try {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CompetitionBookReaderPage(
                                    bookId: widget.competitionBookId,
                                    title: widget.title,
                                  ),
                                ),
                              );

                              if (widget.scrollController != null) {
                                widget.scrollController!.animateTo(
                                  0,
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("فشل تحميل الكتاب")),
                              );
                              print("Download error: $e");
                            }
                          },
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
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                widget.imagePath,
                width: 80,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
