import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/post_card.dart';
import '../../../shared/widgets/user_avatar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  final TextEditingController _postController = TextEditingController();

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == 2) {
      context.go('/create-post');
    } else {
      setState(() => _currentNavIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundFeed,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    CreatePostCard(
                      currentUserName: 'Fatou Sow',
                      currentUserAvatar: null,
                      onTap: () => context.go('/create-post'),
                      onPhoto: () {},
                      onVideo: () {},
                      onEvent: () {},
                    ),
                    const SizedBox(height: 12),
                    _buildFeed(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
        messagesBadgeCount: 3,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.home_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                'UADB SOCIAL',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBlue,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textDark, size: 26),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.badgeRed,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('3', style: AppTextStyles.badgeText),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeed() {
    return Column(
      children: [
        PostCard(
          authorName: 'Aminata Diallo',
          authorRole: 'Licence 3 Informatique',
          timeAgo: 'Il y a 2h',
          content:
              'Super enthousiaste pour le hackathon UADB ce week-end ! 🚀 Qui d\'autre participe ? On va coder des solutions pour l\'agriculture locale. #HackathonUADB #Innovation',
          imageUrl: 'https://picsum.photos/seed/hackathon/400/225',
          likesCount: 24,
          commentsCount: 8,
          sharesCount: 5,
          onLike: () {},
          onComment: () {},
          onShare: () {},
          onProfileTap: () {},
        ),
        const SizedBox(height: 12),
        PostCard(
          authorName: 'Direction Scolarité',
          authorRole: 'Rectorat UADB',
          timeAgo: 'Il y a 5h',
          content:
              'Communiqué officiel : Les examens du premier semestre débuteront le 15 janvier 2025. Consultez le calendrier détaillé sur le portail étudiant. Bonne préparation à tous ! 📚',
          isOfficial: true,
          likesCount: 142,
          commentsCount: 12,
          sharesCount: 28,
          onLike: () {},
          onComment: () {},
          onShare: () {},
          onProfileTap: () {},
        ),
        const SizedBox(height: 12),
        PostCard(
          authorName: 'Moussa Ndiaye',
          authorRole: 'Master 1 Agronomie, SATA',
          timeAgo: 'Hier',
          content:
              'Journée terrain à Nianing avec la promo M1 Agronomie. Analyse des sols et échange avec les paysans locaux. Expérience enrichissante ! 🌾🌱',
          imageUrl: 'https://picsum.photos/seed/terrain/400/225',
          likesCount: 45,
          commentsCount: 3,
          sharesCount: 7,
          onLike: () {},
          onComment: () {},
          onShare: () {},
          onProfileTap: () {},
        ),
      ],
    );
  }
}