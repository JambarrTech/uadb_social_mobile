import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../../shared/widgets/custom_button.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  int _currentNavIndex = 2;
  final TextEditingController _contentController = TextEditingController();
  String _visibility = 'Tout le monde';

  static const List<String> _visibilityOptions = ['Tout le monde', 'Amis', 'Communautés', 'Moi uniquement'];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index != 2) {
      context.go(index == 0 ? '/home' : index == 1 ? '/explore' : index == 3 ? '/messages' : '/profile');
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildAuthorSection(),
                    const SizedBox(height: 16),
                    _buildContentField(),
                    const SizedBox(height: 16),
                    _buildDivider(),
                    const SizedBox(height: 12),
                    _buildAddOptions(),
                    const SizedBox(height: 100),
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
          InkWell(
            onTap: () => context.pop(),
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.close_rounded, color: AppColors.textDark, size: 24),
            ),
          ),
          const Spacer(),
          Text('Nouvelle publication', style: AppTextStyles.createPostTitle),
          const Spacer(),
          CustomButton(
            text: 'Publier',
            onPressed: _contentController.text.trim().isNotEmpty ? _handlePublish : null,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            borderRadius: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorSection() {
    return Row(
      children: [
        UserAvatar(initials: 'FS', radius: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fatou Sow', style: AppTextStyles.postAuthorName.copyWith(fontSize: 14)),
              const SizedBox(height: 2),
              _buildVisibilityDropdown(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVisibilityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _visibility,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textMedium),
          style: AppTextStyles.createPostLabel.copyWith(fontSize: 10, color: AppColors.textMedium),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(8),
          items: _visibilityOptions
              .map((v) => DropdownMenuItem(value: v, child: Text('🟢 Visible par: $v')))
              .toList(),
          onChanged: (v) => setState(() => _visibility = v ?? _visibilityOptions[0]),
        ),
      ),
    );
  }

  Widget _buildContentField() {
    return TextField(
      controller: _contentController,
      maxLines: null,
      minLines: 8,
      style: TextStyle(
        fontFamily: 'Figtree',
        fontSize: 15,
        color: AppColors.textDark,
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText:
            'Quoi de neuf ? Partagez une info avec la communauté de l\'Université Alioune Diop de Bambey...',
        hintStyle: TextStyle(
          fontFamily: 'Figtree',
          fontSize: 15,
          color: AppColors.textMuted,
          height: 1.5,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: AppColors.borderSeparator);
  }

  Widget _buildAddOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AJOUTER À VOTRE PUBLICATION', style: AppTextStyles.createPostLabel.copyWith(fontSize: 11)),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1,
          children: [
            _buildOptionItem(
              icon: Icons.photo_library_rounded,
              label: 'Photo',
              color: AppColors.green,
              onTap: () {},
            ),
            _buildOptionItem(
              icon: Icons.videocam_rounded,
              label: 'Vidéo',
              color: AppColors.primaryBlue,
              onTap: () {},
            ),
            _buildOptionItem(
              icon: Icons.event_rounded,
              label: 'Événement',
              color: AppColors.orangeRed,
              onTap: () {},
            ),
            _buildOptionItem(
              icon: Icons.poll_rounded,
              label: 'Sondage',
              color: const Color(0xFF8B5CF6),
              onTap: () {},
            ),
            _buildOptionItem(
              icon: Icons.location_on_rounded,
              label: 'Lieu',
              color: const Color(0xFFEF4444),
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.createPostLabel.copyWith(fontSize: 9)),
        ],
      ),
    );
  }

  void _handlePublish() {
    if (_contentController.text.trim().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publication créée !')),
      );
      context.pop();
    }
  }
}