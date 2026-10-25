import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/post.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/demo_notice.dart';
import '../../../shared/widgets/inline_error_banner.dart';
import '../../../shared/widgets/responsive.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../auth/state/auth_controller.dart';
import '../../feed/state/feed_controller.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key, this.autoPickImages = false});

  /// Ouvre le sélecteur d'images immédiatement à l'arrivée sur l'écran.
  ///
  /// Déclenché par le bouton « Photo » du composeur de l'accueil : plutôt
  /// que de dupliquer `ImagePicker` (limites, erreurs…), l'écran complet est
  /// réutilisé tel quel et on ouvre simplement sa galerie à l'entrée.
  final bool autoPickImages;

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  static const int _maxLength = 2000;
  static const int _maxImages = 4;

  final TextEditingController _contentController = TextEditingController();
  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();

  PostVisibility _visibility = PostVisibility.public;
  String? _errorMessage;

  /// Verrou de soumission : pendant une publication en cours, un second
  /// appui sur « Publier » est ignoré au lieu d'écrire deux messages.
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoPickImages) {
      // Après le premier rendu : ouvrir un sélecteur système dans
      // `initState` est interdit, le contexte doit être monté.
      WidgetsBinding.instance.addPostFrameCallback((_) => _pickImages());
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _contentController.text.trim().isNotEmpty;

  Future<void> _pickImages() async {
    if (_images.length >= _maxImages) {
      showAppSnackBar(
        context,
        'Vous pouvez joindre au maximum $_maxImages images.',
        isError: true,
      );
      return;
    }
    try {
      final picked = await _picker.pickMultiImage(
        limit: _maxImages - _images.length,
      );
      if (picked.isEmpty) return;
      setState(() => _images.addAll(picked.take(_maxImages - _images.length)));
    } catch (error) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Impossible d’ouvrir la galerie photo.',
        isError: true,
      );
    }
  }

  void _removeImage(int index) => setState(() => _images.removeAt(index));

  void _handlePublish() {
    // Protection anti-double soumission : pendant l'opération, un appui
    // supplémentaire est simplement ignoré.
    if (_isSubmitting) return;

    final content = _contentController.text.trim();
    if (content.isEmpty) return;

    final author = ref.read(currentUserProvider);

    // Aucun serveur : la publication est construite localement puis écrite dans
    // le stockage de l'appareil. Elle réapparaît au prochain lancement.
    _isSubmitting = true;
    try {
      ref
          .read(feedProvider.notifier)
          .add(
            Post(
              id: 'p-${DateTime.now().microsecondsSinceEpoch}',
              authorId: author.id,
              authorName: author.fullName,
              authorRole: author.department ?? '',
              createdAt: DateTime.now(),
              content: content,
              imageUrls: _images.map((image) => image.path).toList(),
            ),
          );
    } finally {
      _isSubmitting = false;
    }

    showAppSnackBar(context, 'Publication enregistrée sur l’appareil.');
    // `pop` referme le flux empilé au-dessus du shell : l'utilisateur retrouve
    // l'onglet d'où il vient.
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundFeed,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              canSubmit: _canSubmit,
              onClose: () => context.pop(),
              onPublish: _handlePublish,
            ),
            Expanded(
              child: AppPage(
                maxWidth: ContentWidth.feed,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _AuthorRow(
                      displayName: user.fullName,
                      avatarUrl: user.avatarUrl,
                      initials: user.initials,
                      visibility: _visibility,
                      onVisibilityChanged: (value) =>
                          setState(() => _visibility = value),
                    ),
                    const SizedBox(height: 16),
                    if (_errorMessage != null) ...[
                      InlineErrorBanner(message: _errorMessage!),
                    ],
                    _ContentField(
                      controller: _contentController,
                      maxLength: _maxLength,
                      onChanged: () => setState(() {}),
                    ),
                    if (_images.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _ImageStrip(images: _images, onRemove: _removeImage),
                    ],
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    _AttachmentOptions(onPhoto: _pickImages),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.canSubmit,
    required this.onClose,
    required this.onPublish,
  });

  final bool canSubmit;
  final VoidCallback onClose;
  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Fermer',
          ),
          const Spacer(),
          const Text(
            'Nouvelle publication',
            style: AppTextStyles.createPostTitle,
          ),
          const Spacer(),
          CustomButton(
            text: 'Publier',
            onPressed: canSubmit ? onPublish : null,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            borderRadius: 18,
          ),
        ],
      ),
    );
  }
}

class _AuthorRow extends StatelessWidget {
  const _AuthorRow({
    required this.displayName,
    required this.avatarUrl,
    required this.initials,
    required this.visibility,
    required this.onVisibilityChanged,
  });

  final String displayName;
  final String? avatarUrl;
  final String? initials;
  final PostVisibility visibility;
  final ValueChanged<PostVisibility> onVisibilityChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        UserAvatar(imageUrl: avatarUrl, initials: initials, radius: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: AppTextStyles.postAuthorName.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 2),
              _VisibilityDropdown(
                value: visibility,
                onChanged: onVisibilityChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VisibilityDropdown extends StatelessWidget {
  const _VisibilityDropdown({required this.value, required this.onChanged});

  final PostVisibility value;
  final ValueChanged<PostVisibility> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<PostVisibility>(
          value: value,
          isDense: true,
          borderRadius: BorderRadius.circular(8),
          dropdownColor: Colors.white,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
          style: AppTextStyles.createPostLabel.copyWith(fontSize: 11),
          items: [
            for (final option in PostVisibility.values)
              DropdownMenuItem(
                value: option,
                child: Text('Visible par : ${option.label}'),
              ),
          ],
          onChanged: (selected) {
            if (selected != null) onChanged(selected);
          },
        ),
      ),
    );
  }
}

class _ContentField extends StatelessWidget {
  const _ContentField({
    required this.controller,
    required this.maxLength,
    required this.onChanged,
  });

  final TextEditingController controller;
  final int maxLength;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: null,
      minLines: 8,
      maxLength: maxLength,
      onChanged: (_) => onChanged(),
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        hintText:
            'Quoi de neuf ? Partagez une info avec la communauté de '
            'l\'Université Alioune Diop de Bambey...',
        counterStyle: AppTextStyles.createPostHint,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

class _ImageStrip extends StatelessWidget {
  const _ImageStrip({required this.images, required this.onRemove});

  final List<XFile> images;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) => Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                images[index].path,
                width: 96,
                height: 96,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 96,
                  height: 96,
                  color: AppColors.borderSeparator,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -6,
              right: -6,
              child: InkWell(
                onTap: () => onRemove(index),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.orangeRed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Options d'ajout à la publication.
///
/// Seule la photo est branchée côté client ; les autres formats dépendent
/// d'endpoints backend non disponibles et sont annoncés comme tels au lieu
/// d'être des boutons inertes.
class _AttachmentOptions extends StatelessWidget {
  const _AttachmentOptions({required this.onPhoto});

  final VoidCallback onPhoto;

  static const List<_AttachmentOption> _options = [
    _AttachmentOption(
      Icons.photo_library_rounded,
      'Photo',
      AppColors.green,
      enabled: true,
    ),
    _AttachmentOption(Icons.videocam_rounded, 'Vidéo', AppColors.primaryBlue),
    _AttachmentOption(Icons.event_rounded, 'Événement', AppColors.orangeRed),
    _AttachmentOption(Icons.poll_rounded, 'Sondage', AppColors.pollPurple),
    _AttachmentOption(Icons.location_on_rounded, 'Lieu', AppColors.locationRed),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AJOUTER À VOTRE PUBLICATION',
          style: AppTextStyles.createPostLabel.copyWith(letterSpacing: 0.5),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            // 5 colonnes sur téléphone, 3 sur les écrans plus larges : la
            // grille s'adapte au lieu d'être figée.
            final columns = constraints.maxWidth > 480 ? 5 : 3;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: columns,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.95,
              children: [
                for (final option in _options) _buildOption(context, option),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildOption(BuildContext context, _AttachmentOption option) {
    final onTap = option.enabled
        ? onPhoto
        : () => showAppSnackBar(
            context,
            '${option.label} : bientôt disponible.',
            isError: true,
          );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: option.enabled ? 1 : 0.55,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: option.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(option.icon, color: option.color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              option.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.createPostLabel.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentOption {
  const _AttachmentOption(
    this.icon,
    this.label,
    this.color, {
    this.enabled = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool enabled;
}
