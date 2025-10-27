// core/features/auth/presentation/widgets/profile_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'rounded_icon_button.dart';

class ProfileHeader extends StatelessWidget {
  final String username;
  final int points;
  final VoidCallback onEditProfile;
  final List<Map<String, dynamic>> actions; // [{icon:'assets/..', onTap: (){}}]

  const ProfileHeader({
    Key? key,
    required this.username,
    required this.points,
    required this.onEditProfile,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        // الخلفية المثلثية / درجات الأزرق
        ClipPath(
          clipper: _HeaderClipper(),
          child: Container(
            height: 240,
            color: Color(0xFF2C6B86), // رئيسي (ضبطي ليناسب الصورة)
            child: Stack(
              children: [
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(width: screenW*0.6, color: Color(0xFF1F5970).withOpacity(0.25)),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Avatar واسم و أيقونات
        Positioned(
          top: 32,
          left: 0,
          right: 0,
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 36,
                  backgroundImage: AssetImage('assets/icons/profile.png'),
                ),
              ),
              SizedBox(height: 8),
              Text(username, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
              SizedBox(height: 12),
              // ايقونات صغيرة في صف
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: actions.map((a) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: RoundedIconButton(
                      assetName: a['icon'] as String,
                      onTap: a['onTap'] as VoidCallback,
                      size: 44,
                    ),
                  );
                }).toList(),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.lineTo(0, size.height*0.7);
    p.quadraticBezierTo(size.width*0.15, size.height*0.95, size.width*0.4, size.height*0.85);
    p.lineTo(size.width, size.height*0.7);
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
