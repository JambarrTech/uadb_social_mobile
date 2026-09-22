import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/user_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentNavIndex = 4;

  void _onNavTap(int index) {
    if (index == 2) {
      context.go('/create-post');
    } else {
      context.go(index == 0 ? '/home' : index == 1 ? '/explore' : index == 3 ? '/messages' : '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundFeed,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(),
              _buildStatsRow(),
              const SizedBox(height: 16),
              _buildMenuOptions(),
              const SizedBox(height: 100),
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

  Widget _buildProfileHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Column(
        children: [
          UserAvatar(initials: 'FS', radius: 50),
          const SizedBox(height: 16),
          Text('Fatou Sow', style: AppTextStyles.postAuthorName.copyWith(fontSize: 22)),
          const SizedBox(height: 4),
          Text('Licence 3 Informatique', style: AppTextStyles.postAuthorRole.copyWith(fontSize: 13)),
          const SizedBox(height: 4),
          Text('@fatou.sow', style: AppTextStyles.postTime.copyWith(fontSize: 13)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
                child: Text('Modifier le profil', style: AppTextStyles.buttonPrimary.copyWith(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn('Publications', '24'),
          _buildVerticalDivider(),
          _buildStatColumn('Abonnés', '1.2k'),
          _buildVerticalDivider(),
          _buildStatColumn('Abonnements', '342'),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.postAuthorName.copyWith(fontSize: 18)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.postAuthorRole.copyWith(fontSize: 11)),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 32, color: AppColors.borderSeparator);
  }

  Widget _buildMenuOptions() {
    final options = [
      {'icon': Icons.person_outline_rounded, 'title': 'Mon profil', 'subtitle': 'Informations personnelles'},
      {'icon': Icons.bookmark_outline_rounded, 'title': 'Mes favoris', 'subtitle': 'Publications sauvegardées'},
      {'icon': Icons.group_outlined, 'title': 'Mes communautés', 'subtitle': 'Groupes rejoints'},
      {'icon': Icons.event_outlined, 'title': 'Mes événements', 'subtitle': 'Événements à venir'},
      {'icon': Icons.settings_outlined, 'title': 'Paramètres', 'subtitle': 'Confidentialité, notifications'},
      {'icon': Icons.help_outline_rounded, 'title': 'Aide & Support', 'subtitle': 'FAQ, contact'},
      {'icon': Icons.logout_rounded, 'title': 'Déconnexion', 'subtitle': 'Se déconnecter', 'isDestructive': true},
    ];

    return Column(
      children: options.map((opt) => _buildMenuItem(
        icon: opt['icon'] as IconData,
        title: opt['title'] as String,
        subtitle: opt['subtitle'] as String,
        isDestructive: opt['isDestructive'] == true,
      )).toList(),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isDestructive = false,
  }) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDestructive
                  ? AppColors.orangeRed.withValues(alpha: 0.1)
                  : AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: isDestructive ? AppColors.orangeRed : AppColors.primaryBlue, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.postAuthorName.copyWith(
                  fontSize: 14,
                  color: isDestructive ? AppColors.orangeRed : AppColors.textDark,
                )),
                Text(subtitle, style: AppTextStyles.postAuthorRole.copyWith(fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}