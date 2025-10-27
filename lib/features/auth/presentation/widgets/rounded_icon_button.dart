// core/features/auth/presentation/widgets/rounded_icon_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RoundedIconButton extends StatelessWidget {
  final String assetName;
  final VoidCallback onTap;
  final double size;

  const RoundedIconButton({
    Key? key,
    required this.assetName,
    required this.onTap,
    this.size = 48,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0,2))],
        ),
        padding: EdgeInsets.all(10),
        child: SvgPicture.asset(
          assetName,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
