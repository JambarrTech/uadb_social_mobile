import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/post.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'demo_notice.dart';
import 'image_viewer.dart';
import 'post_image.dart';
import 'user_avatar.dart';

/// Carte d'une publication.
///
/// Fidèle à la maquette de référence, organisée en quatre parties :
/// 1. l'en-tête (avatar + nom + informations secondaires + menu à trois
///    points horizontaux) ;
/// 2. le contenu textuel (13 px, interligne confortable, retours à la
///    ligne naturels, pas de troncature) ;
/// 3. la galerie d'images (une image pleine largeur, deux images côte à
///    côte, un aperçu « +N » au-delà) ;
/// 4. la barre d'actions (J'aime, Commenter, Partager, puis Enregistrer
///    à l'extrémité droite).
///
/// La carte est purement présentationnelle : les compteurs et les états
/// « aimé » ou « enregistré » proviennent des données de la publication
/// et des gestionnaires d'état de l'appelant ; elle ne contient aucune
/// logique de réseau ni de simulation de sauvegarde serveur.
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onAuthorTap,
    this.isSaved = false,
    this.onToggleSave,
  });

  final Post post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onAuthorTap;

  /// Publication déjà enregistrée dans les favoris de l'appareil.
  final bool isSaved;

  /// Ajoute ou retire la publication des favoris.
  final VoidCallback? onToggleSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(10),
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
        // 12 px horizontaux : grille gauche commune au composeur et aux
        // publications (les avatars restent à l'aplomb sur toute la page),
        // 10 px verticaux conformes à la maquette.
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              post: post,
              onAuthorTap: onAuthorTap,
              onMenuTap: () => _showPostMenu(context),
            ),
            if (post.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(post.content, style: AppTextStyles.postContent),
            ],
            if (post.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 6),
              _ImageGallery(
                urls: post.imageUrls,
                onTapImage: (index) => showImageViewer(
                  context,
                  urls: post.imageUrls,
                  initialIndex: index,
                ),
              ),
            ],
            const SizedBox(height: 8),
            const Divider(height: 1, color: AppColors.borderSeparator),
            const SizedBox(height: 4),
            _ActionBar(
              post: post,
              onLike: onLike,
              onComment: onComment,
              onShare: onShare,
              isSaved: isSaved,
              onToggleSave: onToggleSave,
            ),
          ],
        ),
      ),
    );
  }

  /// Menu d'actions de la publication : les actions déjà disponibles dans
  /// le projet (enregistrement local, copie du texte), rien de simulé.
  ///
  /// Les retours utilisateur (snackbars) sont émis depuis le contexte de la
  /// carte, qui reste monté après fermeture de la feuille modale ; sinon le
  /// `context` de la feuille, désinséré au pop, ferait échouer le message.
  Future<void> _showPostMenu(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _PostMenuSheet(
        options: [
          if (onToggleSave != null)
            _OptionsMenu(
              icon: isSaved
                  ? Icons.bookmark_remove_outlined
                  : Icons.bookmark_add_outlined,
              label: isSaved
                  ? 'Retirer des favoris'
                  : 'Enregistrer la publication',
              onPressed: onToggleSave!,
            ),
          if (post.content.isNotEmpty)
            _OptionsMenu(
              icon: Icons.copy_rounded,
              label: 'Copier le texte',
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: post.content));
                if (context.mounted) {
                  showAppSnackBar(context, 'Texte copié.');
                }
              },
            ),
          _OptionsMenu(
            icon: Icons.outlined_flag_outlined,
            label: 'Signaler',
            danger: true,
            onPressed: () => showAppSnackBar(
              context,
              'Signalement : bientôt disponible.',
              isError: true,
            ),
          ),
        ],
      ),
    );
  }
}

/// Feuille modale du menu d'une publication : rend simplement les options
/// construites par la carte (libellés, icônes, flux d'exécution).
class _PostMenuSheet extends StatelessWidget {
  const _PostMenuSheet({required this.options});

  final List<_OptionsMenu> options;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (final option in options) _MenuEntry(option: option)],
      ),
    );
  }
}

/// Descripteur d'une option du menu : icône, libellé, éventuellement en
/// danger, et le flux à exécuter après fermeture de la feuille.
class _OptionsMenu {
  const _OptionsMenu({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool danger;
}

/// Rendu d'une option : la feuille se ferme d'abord, puis le flux lié à la
/// carte s'exécute (le `context` de la feuille n'est plus utilisé ensuite).
class _MenuEntry extends StatelessWidget {
  const _MenuEntry({required this.option});

  final _OptionsMenu option;

  @override
  Widget build(BuildContext context) {
    final color = option.danger ? AppColors.orangeRed : AppColors.textDark;
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        option.onPressed();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(option.icon, size: 20, color: color),
            const SizedBox(width: 14),
            // Expanded : le libellé reste borné à la largeur de la feuille
            // (et ne fait jamais déborder la ligne, quelle que soit la
            // police du système ou le facteur d'échelle des textes).
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(fontSize: 14, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 1 — En-tête : avatar, identité et menu d'actions.
class _Header extends StatelessWidget {
  const _Header({
    required this.post,
    this.onAuthorTap,
    required this.onMenuTap,
  });

  final Post post;
  final VoidCallback? onAuthorTap;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    final role = post.authorRole;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Appui sur l'identité : remonte l'écran de profil via
        // [onAuthorTap] quand l'intégrateur en fournit un.
        InkWell(
          onTap: onAuthorTap,
          customBorder: const CircleBorder(),
          child: UserAvatar(
            initials: _initialsOf(post.authorName),
            // 2 × 15 = 30 px de diamètre : la fourchette 28-32 px de la
            // maquette, en ligne avec l'avatar du composeur (28 px).
            radius: 15,
            backgroundColor: _avatarColor(post),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: InkWell(
            onTap: onAuthorTap,
            borderRadius: BorderRadius.circular(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        post.authorName.isEmpty
                            ? 'Utilisateur'
                            : post.authorName,
                        // « Licence 3 Informat... » de la maquette : le nom
                        // long se tronque sur une seule ligne, sans jamais
                        // pousser la carte à débordement.
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: AppTextStyles.postAuthorName,
                      ),
                    ),
                    if (post.isOfficial) ...[
                      const SizedBox(width: 6),
                      const _OfficialBadge(),
                    ],
                  ],
                ),
                // Un filet d'air sépare le nom des informations
                // secondaires : à 13/10 px collés, le bloc paraît serré.
                const SizedBox(height: 2),
                Text(
                  role.isEmpty ? post.timeAgo() : '$role · ${post.timeAgo()}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: AppTextStyles.postAuthorRole,
                ),
              ],
            ),
          ),
        ),
        _MenuButton(onTap: onMenuTap),
      ],
    );
  }
}

/// Bouton « trois points horizontaux » : ouvre le menu d'actions de la
/// publication (voir [PostCard._showPostMenu]).
class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Options de la publication',
      onPressed: onTap,
      icon: const Icon(Icons.more_horiz, size: 18),
      color: AppColors.textMuted,
      // Icône compacte (18 px) sur une cible tactile franche (36 px) :
      // la maquette exige une icône discrète, pas une cible minuscule.
      padding: const EdgeInsets.all(9),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      visualDensity: VisualDensity.compact,
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

/// Initiales d'un auteur : premières lettres des deux premiers mots
/// (« Aminata Diallo » → « AD »), sans cas dégénéré (masque vide/non défini).
String _initialsOf(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .toList();
  if (parts.isEmpty) return '?';
  return parts.map((part) => part[0]).join().toUpperCase();
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

/// 3 — Galerie d'images : une image pleine largeur, deux images côte à
/// côte (hauteurs égales, largeurs équilibrées), deux visibles + compteur
/// « +N » au-delà. Chaque vignette ouvre la visionneuse plein écran.
class _ImageGallery extends StatelessWidget {
  const _ImageGallery({required this.urls, required this.onTapImage});

  final List<String> urls;
  final void Function(int index) onTapImage;

  static const double _singleImageHeight = 180;
  static const double _pairImageHeight = 140;
  static const double _gap = 5;

  @override
  Widget build(BuildContext context) {
    if (urls.length == 1) {
      return _thumbnail(0, height: _singleImageHeight);
    }

    // Au-delà de deux images, on n'affiche qu'un aperçu pour garder une
    // carte compacte : deux vignettes équilibrées, la deuxième recouverte
    // d'une pastille « +N ». [Expanded] garantit des largeurs égales.
    final visible = urls.take(2).toList();
    return SizedBox(
      height: _pairImageHeight,
      child: Row(
        children: [
          for (var i = 0; i < visible.length; i++) ...[
            Expanded(
              child: _thumbnail(
                i,
                height: _pairImageHeight,
                remaining: urls.length > 2 && i == 1 ? urls.length - 2 : 0,
              ),
            ),
            if (i < visible.length - 1) const SizedBox(width: _gap),
          ],
        ],
      ),
    );
  }

  Widget _thumbnail(int index, {required double height, int remaining = 0}) {
    final url = urls[index];
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTapImage(index),
            child: _image(url, height),
          ),
          if (remaining > 0)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => onTapImage(index),
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
            ),
        ],
      ),
    );
  }

  /// Rend l'image d'une publication, quelle que soit son origine : asset
  /// embarqué pour le contenu de démonstration, URL distante pour les
  /// publications réelles, fichier local pour les photos choisies dans
  /// l'app (voir [PostImage]). En cas d'échec de chargement, un repli
  /// neutralise l'erreur sans casser la mise en page.
  Widget _image(String url, double height) =>
      PostImage(url: url, height: height, width: double.infinity);
}

/// 4 — Barre d'actions : J'aime, Commenter, Partager, puis Enregistrer à
/// l'extrémité droite (les deux premiers affichent leur compteur).
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    required this.isSaved,
    this.onToggleSave,
  });

  final Post post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final bool isSaved;
  final VoidCallback? onToggleSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // J'aime : cœur rouge de la maquette, rempli quand la publication
        // est déjà aimée, contour sinon — l'état « J'aime » reste lisible.
        _Action(
          icon: post.likedByMe
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          label: _formatCount(post.likesCount),
          color: post.likedByMe ? AppColors.locationRed : AppColors.textMuted,
          onTap: onLike,
        ),
        // Commenter : accent bleu du projet ; aucune interface de
        // commentaires n'existe encore, un état explicite l'annonce
        // plutôt que de simuler des données.
        _Action(
          icon: Icons.chat_bubble_outline_rounded,
          label: _formatCount(post.commentsCount),
          color: AppColors.primaryBlue,
          onTap:
              onComment ??
              () => showAppSnackBar(
                context,
                'Commentaires : bientôt disponible.',
                isError: true,
              ),
        ),
        // Partager : gris foncé, sans compteur, comme sur la maquette ; le
        // mécanisme existant (compteur local du fil) reste appelé.
        _ShareAction(onTap: onShare),
        // Enregistrer : pousse à l'extrémité droite, espace libre à gauche.
        const Spacer(),
        _SaveAction(isSaved: isSaved, onTap: onToggleSave),
      ],
    );
  }
}

/// Action à compteur : icône colorée + nombre fourni par la publication.
///
/// La cible tactile reste franche (icône 18 px sur ~32 px de haut) même
/// si l'icône paraît petite à l'écran.
class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 5),
            Text(label, style: AppTextStyles.interactionCount),
          ],
        ),
      ),
    );
  }
}

/// Action « Partager » : icône seule, gris foncé, comme sur la maquette.
class _ShareAction extends StatelessWidget {
  const _ShareAction({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 7),
        child: Icon(
          Icons.share_outlined,
          size: 18,
          color: AppColors.textMedium,
        ),
      ),
    );
  }
}

/// Action « Enregistrer » : signet à droite, contour quand la publication
/// n'est pas enregistrée, rempli quand elle l'est.
class _SaveAction extends StatelessWidget {
  const _SaveAction({required this.isSaved, required this.onTap});

  final bool isSaved;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
        child: Icon(
          isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          size: 18,
          color: isSaved ? AppColors.primaryBlue : AppColors.textMuted,
        ),
      ),
    );
  }
}

String _formatCount(int value) {
  if (value < 1000) return '$value';
  if (value < 10000) return '${(value / 1000).toStringAsFixed(1)} k';
  return '${(value / 1000).round()} k';
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
