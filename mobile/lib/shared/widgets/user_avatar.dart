import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double radius;
  final bool isVerified;
  final Color? backgroundColor;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.radius = 20,
    this.isVerified = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? _getColorFromInitials(initials ?? '');

    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: bgColor,
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
          child: imageUrl == null
              ? Text(
                  initials ?? '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: radius * 0.6,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'SpaceGrotesk',
                  ),
                )
              : null,
        ),
        if (isVerified)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                size: radius * 0.35,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Color _getColorFromInitials(String initials) {
    final colors = [
      const Color(0xFF00449B),
      const Color(0xFF12912F),
      const Color(0xFFC85A43),
      const Color(0xFF8B5CF6),
      const Color(0xFFEF4444),
      const Color(0xFF06B6D4),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
    ];
    int hash = 0;
    for (var i = 0; i < initials.length; i++) {
      hash = initials.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return colors[hash.abs() % colors.length];
  }
}

class UserAvatarWithBorder extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double radius;
  final Color borderColor;
  final double borderWidth;

  const UserAvatarWithBorder({
    super.key,
    this.imageUrl,
    this.initials,
    this.radius = 20,
    this.borderColor = AppColors.cardWhite,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: UserAvatar(
        imageUrl: imageUrl,
        initials: initials,
        radius: radius - borderWidth,
      ),
    );
  }
}