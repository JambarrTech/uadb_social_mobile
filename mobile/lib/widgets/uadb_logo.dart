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
    final circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_rounded, size: size * 0.28, color: AppColors.green),
          SizedBox(height: size * 0.02),
          Text(
            'UADB',
            style: TextStyle(
              fontSize: size * 0.14,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              height: 1,
              letterSpacing: 0.6,
            ),
          ),
          Text(
            'SOCIAL',
            style: TextStyle(
              fontSize: size * 0.09,
              fontWeight: FontWeight.w700,
              color: AppColors.green,
              letterSpacing: 1.4,
              height: 1.2,
            ),
          ),
        ],
      ),
    );

    if (!showTagline) return circle;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        circle,
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
