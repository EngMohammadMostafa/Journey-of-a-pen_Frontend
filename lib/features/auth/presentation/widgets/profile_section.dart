// core/features/auth/presentation/widgets/profile_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconAsset;
  final VoidCallback? onTap;

  const ProfileSection({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 18),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Color(0xFF2E3A3F), // غامق
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            Text(subtitle, style: TextStyle(color: Colors.white70)),
            SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              padding: EdgeInsets.all(8),
              child: SvgPicture.asset(iconAsset, width: 18, height: 18),
            )
          ],
        ),
      ),
    );
  }
}
