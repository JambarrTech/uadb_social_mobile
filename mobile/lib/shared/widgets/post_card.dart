import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'user_avatar.dart';

class PostCard extends StatelessWidget {
  final String authorName;
  final String authorRole;
  final String timeAgo;
  final String content;
  final String? imageUrl;
  final bool isOfficial;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onProfileTap;

  const PostCard({
    super.key,
    required this.authorName,
    required this.authorRole,
    required this.timeAgo,
    required this.content,
    this.imageUrl,
    this.isOfficial = false,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Text(content, style: AppTextStyles.postContent),
          ),
          if (imageUrl != null) _buildImage(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: InkWell(
        onTap: onProfileTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            UserAvatar(
              initials: _getInitials(authorName),
              radius: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          authorName,
                          style: AppTextStyles.postAuthorName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isOfficial) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.officialBadge,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'OFFICIEL',
                            style: AppTextStyles.officialBadge,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(authorRole, style: AppTextStyles.postAuthorRole),
                      const SizedBox(width: 8),
                      Text(timeAgo, style: AppTextStyles.postTime),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl!,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 200,
            color: AppColors.borderSeparator,
            child: const Icon(Icons.image_not_supported, color: AppColors.textMuted),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Row(
        children: [
          _buildActionButton(
            icon: Icons.favorite_border_rounded,
            count: likesCount,
            onTap: onLike,
          ),
          const SizedBox(width: 24),
          _buildActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            count: commentsCount,
            onTap: onComment,
          ),
          const Spacer(),
          _buildActionButton(
            icon: Icons.share_rounded,
            count: sharesCount,
            onTap: onShare,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required int count,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: AppColors.textMedium),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: AppTextStyles.interactionCount,
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class CreatePostCard extends StatelessWidget {
  final String currentUserName;
  final String? currentUserAvatar;
  final VoidCallback onTap;
  final VoidCallback? onPhoto;
  final VoidCallback? onVideo;
  final VoidCallback? onEvent;

  const CreatePostCard({
    super.key,
    required this.currentUserName,
    this.currentUserAvatar,
    required this.onTap,
    this.onPhoto,
    this.onVideo,
    this.onEvent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSeparator),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  UserAvatar(
                    initials: _getInitials(currentUserName),
                    radius: 18,
                    imageUrl: currentUserAvatar,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Quoi de neuf ? Partagez une info...',
                      style: AppTextStyles.createPostHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 1,
            color: AppColors.borderSeparator,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOptionButton(
                  icon: Icons.photo_library_rounded,
                  label: 'Photo',
                  iconColor: AppColors.green,
                  onTap: onPhoto,
                ),
                _buildOptionButton(
                  icon: Icons.videocam_rounded,
                  label: 'Vidéo',
                  iconColor: AppColors.primaryBlue,
                  onTap: onVideo,
                ),
                _buildOptionButton(
                  icon: Icons.event_rounded,
                  label: 'Événement',
                  iconColor: AppColors.orangeRed,
                  onTap: onEvent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.createPostLabel),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}