import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class UadbLogo extends StatelessWidget {
  const UadbLogo({
    super.key,
    this.size = 168,
    this.showTagline = false,
    this.light = false,
  });

  final double size;
  final bool showTagline;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final logo = ClipOval(
      child: Image.asset(
        'logo.jpeg',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );

    if (!showTagline) return logo;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        logo,
        const SizedBox(height: 28),
        Text(
          'Le réseau de votre communauté.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: light ? Colors.white : AppColors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
