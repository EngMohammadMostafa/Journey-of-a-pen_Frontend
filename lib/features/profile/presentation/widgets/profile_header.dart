import 'package:flutter/material.dart';
import 'rounded_icon_button.dart';

class ProfileHeader extends StatelessWidget {
  final String username;
  final int points;
  final VoidCallback onEditProfile;
  final List<Map<String, dynamic>> actions;

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
      clipBehavior: Clip.none,
      children: [
        ClipPath(
          clipper: _HeaderClipper(),
          child: Container(
            height: 260,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1C597B),
                  Color(0xFF4C869F),
                  Color(0xFF7199AA),],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),

        Positioned(
          top: 40,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // الصورة الشخصية
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 41,
                  backgroundImage: AssetImage('assets/icons/profile.png'),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                username,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // صف الأيقونات
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: actions.map((a) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: RoundedIconButton(
                      assetName: a['icon'] as String,
                      onTap: a['onTap'] as VoidCallback,
                      size: 50,
                    ),
                  );
                }).toList(),
              ),
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
    p.lineTo(0, size.height * 0.75);
    p.quadraticBezierTo(
        size.width * 0.25, size.height, size.width * 0.55, size.height * 0.85);
    p.lineTo(size.width, size.height * 0.7);
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
