import 'package:flutter/material.dart';

import '../../core/models/post.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'demo_notice.dart';
import 'user_avatar.dart';

/// Carte d'une publication.
///
/// Les compteurs et l'état « liké » sont fournis par l'appelant : la carte est
/// purely présentenelle et ne contient aucune logique de réseau.
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onAuthorTap,
  });

  final Post post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onAuthorTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSeparator),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(post: post, onAuthorTap: onAuthorTap),
            if (post.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                post.content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.textDark,
                ),
              ),
            ],
            if (post.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 10),
              _ImageGrid(urls: post.imageUrls),
            ],
            const SizedBox(height: 8),
            const Divider(height: 1, color: AppColors.borderSeparator),
            const SizedBox(height: 6),
            _Footer(
              post: post,
              onLike: onLike,
              onComment: onComment,
              onShare: onShare,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.post, this.onAuthorTap});

  final Post post;
  final VoidCallback? onAuthorTap;

  @override
  Widget build(BuildContext context) {
    final role = post.authorRole;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: onAuthorTap,
          customBorder: const CircleBorder(),
          child: UserAvatar(
            initials: post.authorName,
            radius: 18,
            backgroundColor: _avatarColor(post),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      post.authorName.isEmpty ? 'Utilisateur' : post.authorName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  if (post.isOfficial) ...[
                    const SizedBox(width: 6),
                    const _OfficialBadge(),
                  ],
                ],
              ),
              const SizedBox(height: 1),
              Text(
                role.isEmpty ? post.timeAgo() : '$role · ${post.timeAgo()}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.more_vert, size: 20, color: AppColors.textMuted),
      ],
    );
  }
}

/// Couleur d'avatar imposée par la maquette, ou `null` pour laisser
/// l'avatar choisir sa teinte à partir des initiales.
///
/// Seul le format hexadécimal `#RRGGBB` est accepté : toute valeur
/// malformée est ignorée plutôt que de faire échouer le rendu du fil.
Color? _avatarColor(Post post) {
  final raw = post.avatarColor;
  if (raw == null) return null;
  final value = raw.replaceFirst('#', '');
  if (value.length != 6) return null;
  final parsed = int.tryParse(value, radix: 16);
  if (parsed == null) return null;
  return Color(0xFF000000 | parsed);
}

/// Petit badge vert « Officiel » posé à côté du nom d'un compte vérifié.
class _OfficialBadge extends StatelessWidget {
  const _OfficialBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'Officiel',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ImageGrid extends StatelessWidget {
  const _ImageGrid({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    if (urls.length == 1) {
      return _thumbnail(urls.first, height: 180);
    }

    // Au-delà de deux images, on n'affiche qu'un aperçu pour garder une carte
    // compacte.
    final visible = urls.take(2).toList();
    return SizedBox(
      height: 160,
      child: Row(
        children: [
          for (var i = 0; i < visible.length; i++) ...[
            Expanded(
              child: _thumbnail(
                visible[i],
                height: 160,
                remaining: urls.length > 2 && i == 1 ? urls.length - 2 : 0,
              ),
            ),
            if (i < visible.length - 1) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }

  Widget _thumbnail(String url, {required double height, int remaining = 0}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          _image(url, height),
          if (remaining > 0)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.45),
                alignment: Alignment.center,
                child: Text(
                  '+$remaining',
                  style: AppTextStyles.createPostTitle.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Rend l'image d'une publication.
  ///
  /// Les photos de démonstration sont embarquées dans les assets (chemins
  /// `assets/…`) pour que le fil reste illustré hors ligne ; les publications
  /// réelles, elles, portent des URL distantes. On distingue les deux sans
  /// modifier le modèle : un chemin asset ne contient jamais de schéma
  /// `http(s)`, donc il est impossible de confondre les deux cas.
  Widget _image(String url, double height) {
    if (_isAssetPath(url)) {
      return Image.asset(
        url,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _imageFallback(height),
      );
    }
    return Image.network(
      url,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _imageFallback(height),
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : Container(height: height, color: AppColors.borderSeparator),
    );
  }

  static bool _isAssetPath(String url) =>
      !url.startsWith('http://') && !url.startsWith('https://');

  Widget _imageFallback(double height) => Container(
    height: height,
    color: AppColors.borderSeparator,
    child: const Icon(
      Icons.image_not_supported_outlined,
      color: AppColors.textMuted,
    ),
  );
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
  });

  final Post post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Action(
          icon: post.likedByMe
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          label: _formatCount(post.likesCount),
          color: post.likedByMe ? AppColors.primaryBlue : AppColors.textMuted,
          onTap: onLike,
        ),
        const SizedBox(width: 4),
        _Action(
          icon: Icons.chat_bubble_outline_rounded,
          label: _formatCount(post.commentsCount),
          onTap: onComment,
        ),
        const SizedBox(width: 4),
        _Action(
          icon: Icons.share_outlined,
          label: _formatCount(post.sharesCount),
          onTap: onShare,
        ),
        const Spacer(),
        InkWell(
          onTap: () =>
              showAppSnackBar(context, 'Enregistrement bientôt disponible.'),
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(
              Icons.bookmark_border_rounded,
              size: 20,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

String _formatCount(int value) {
  if (value < 1000) return '$value';
  if (value < 10000) return '${(value / 1000).toStringAsFixed(1)} k';
  return '${(value / 1000).round()} k';
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.textMedium,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte d'invitation à publier, affichée en tête du fil.
class CreatePostCard extends StatelessWidget {
  const CreatePostCard({
    super.key,
    required this.displayName,
    this.avatarUrl,
    this.initials,
    this.onTap,
  });

  final String displayName;
  final String? avatarUrl;
  final String? initials;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderSeparator.withValues(alpha: 0.6),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              UserAvatar(imageUrl: avatarUrl, initials: initials, radius: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundAuth,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Quoi de neuf, $displayName ?',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.createPostHint.copyWith(fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
