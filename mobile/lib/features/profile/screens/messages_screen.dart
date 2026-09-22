import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  int _currentNavIndex = 3;

  void _onNavTap(int index) {
    if (index == 2) {
      context.go('/create-post');
    } else {
      context.go(index == 0 ? '/home' : index == 1 ? '/explore' : index == 4 ? '/profile' : '/messages');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundFeed,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline_rounded, size: 80, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text('Messages', style: AppTextStyles.createPostTitle),
              const SizedBox(height: 8),
              Text('Vos conversations apparaîtront ici', style: AppTextStyles.loginSubtitle),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
        messagesBadgeCount: 3,
      ),
    );
  }
}