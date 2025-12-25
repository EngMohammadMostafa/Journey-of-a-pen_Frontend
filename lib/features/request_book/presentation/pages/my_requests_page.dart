import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/api/api_service.dart';
import '../../../../core/constants/api_endpoints.dart';

class MyRequestsPage extends StatefulWidget {
  const MyRequestsPage({super.key});

  @override
  State<MyRequestsPage> createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends State<MyRequestsPage> {
  final ApiService api = ApiService();
  bool _loading = true;
  List<Map<String, dynamic>> requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _loading = true);
    try {
      final response = await api.get(ApiEndpoints.myRequests);
      if (response.statusCode == 200) {
        final data = List<Map<String, dynamic>>.from(response.data);
        setState(() => requests = data);
      } else {
        setState(() => requests = []);
      }
    } catch (e) {
      debugPrint("Error loading requests: $e");
      setState(() => requests = []);
    } finally {
      setState(() => _loading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
            Column(
              children: [
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: AppBar(
                      elevation: 0,
                      title: const Text('طلباتي'),
                      centerTitle: true,
                      backgroundColor: const Color(0xFF1C597B).withOpacity(0.85),
                    ),
                  ),
                ),

                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : requests.isEmpty
                      ? const Center(
                    child: Text(
                      "لا توجد طلبات حتى الآن",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  )
                      : RefreshIndicator(
                    onRefresh: _loadRequests,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: requests.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final request = requests[index];
                        return _RequestCard(
                          title: request['title'] ?? 'بدون عنوان',
                          status: request['status'] ?? 'pending',
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final String title;
  final String status;

  const _RequestCard({
    required this.title,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final statusData = _statusInfo(status);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF35677A),
            Color(0xFF4C869F),
            Color(0xFF7199AA),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Text(
            'طلب نشر كتاب',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ),
        trailing: _StatusBadge(
          text: statusData['text']!,
          color: statusData['color']!,
          icon: statusData['icon']!,
        ),
      ),
    );
  }

  Map<String, dynamic> _statusInfo(String status) {
    switch (status) {
      case 'accepted':
        return {'text': 'مقبول', 'color': Colors.greenAccent, 'icon': Icons.check_circle};
      case 'rejected':
        return {'text': 'مرفوض', 'color': Colors.redAccent, 'icon': Icons.cancel};
      default:
        return {'text': 'قيد المراجعة', 'color': Colors.orangeAccent, 'icon': Icons.hourglass_bottom};
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;

  const _StatusBadge({
    required this.text,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
