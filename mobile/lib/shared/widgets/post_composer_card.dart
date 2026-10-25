import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'user_avatar.dart';

/// Teintes du champ pilule, dérivées de la palette chaude du projet
/// (`borderSeparator` = 0xFFEBE7DF). La maquette demande un fond
/// « légèrement gris-beige » nettement perceptible sur la carte blanche,
/// avec une bordure fine gris clair : ces deux nuances de la même gamme
/// garantissent le contraste sans introduire de couleurs étrangères.
const Color _pillFill = Color(0xFFF1F0EB);
const Color _pillBorder = Color(0xFFE3DFD5);

/// Carte de création de publication placée immédiatement sous le header de
/// l'accueil.
///
/// Reproduction fidèle de la maquette, deux rangées distinctes :
/// - rangée 1 : avatar circulaire de 28 px + champ pilule
///   « Quoi de neuf ? Partagez une info... ». C'est un vrai [TextField], en
///   lecture seule : l'appui dans le champ remonte [onTapField] et ouvre
///   l'interface de création de publication existante ;
/// - rangée 2 : actions « Photo » (icône image bleue), « Vidéo » (icône
///   caméra rouge), « Événement » (icône calendrier orange), puis le bouton
///   principal « Publier » à droite (fond bleu foncé, texte blanc).
///
/// Robustesse :
/// - les trois actions vivent dans un [FittedBox] `scaleDown` : sur les
///   largeurs les plus étroites (360 px) le groupe se réduit
///   proportionnellement au lieu de déborder, sans jamais rogner un
///   libellé ;
/// - les icônes et leurs libellés sont alignés verticalement (Row) et les
///   [InkWell] de chaque action garantissent une zone tactile franche.
///
/// Le widget est volontairement muet : l'écran qui l'intègre fournit les
/// rappels, ce qui permet de le réutiliser tel quel ailleurs.
class PostComposerCard extends StatelessWidget {
  const PostComposerCard({
    super.key,
    required this.displayName,
    this.avatarUrl,
    this.initials,
    required this.onTapField,
    required this.onTapPhoto,
    required this.onTapVideo,
    required this.onTapEvent,
    required this.onTapPublish,
  });

  /// Nom affichable de l'utilisateur connecté ; conservé pour l'API du
  /// composeur (identité de l'auteur du futur message).
  final String displayName;

  /// Image de l'avatar si disponible ; sinon [UserAvatar] affiche les
  /// [initials].
  final String? avatarUrl;
  final String? initials;

  /// Appui sur le champ pilule : ouvre l'interface de création complète.
  final VoidCallback onTapField;

  /// Sélecteur d'images du projet.
  final VoidCallback onTapPhoto;

  /// Sélecteur vidéo, si la fonction est disponible ; sinon l'écran
  /// intégrateur affiche un état explicite.
  final VoidCallback onTapVideo;

  /// Formulaire de création d'événement, si présent dans le projet.
  final VoidCallback onTapEvent;

  /// Flux de publication actuel, avec sa validation de contenu.
  final VoidCallback onTapPublish;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSeparator),
      ),
      child: Column(
        children: [
          // Rangée 1 : l'InkWell englobe toute la rangée (avatar compris) —
          // un appui hors du pilule ouvre lui aussi l'interface de création.
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            onTap: onTapField,
            child: Padding(
              // 12 px horizontaux = padding interne des [PostCard] du fil :
              // l'avatar du composeur reste à l'aplomb de ceux des
              // publications (grille gauche commune à toute l'écran).
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Row(
                children: [
                  UserAvatar(
                    imageUrl: avatarUrl,
                    initials: initials,
                    // 2 × 14 = 28 px : diamètre imposé par la maquette.
                    radius: 14,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: _PillField(onTap: onTapField)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                // Le groupe d'actions occupe l'espace restant et se réduit
                // proportionnellement plutôt que de déborder : « Photo »,
                // « Vidéo » et « Événement » tiennent à 360 px comme à
                // 412 px, sans jamais rogner un libellé.
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ComposerAction(
                          icon: Icons.image_outlined,
                          label: 'Photo',
                          color: AppColors.primaryBlue,
                          onTap: onTapPhoto,
                        ),
                        _ComposerAction(
                          icon: Icons.videocam_outlined,
                          label: 'Vidéo',
                          color: AppColors.locationRed,
                          onTap: onTapVideo,
                        ),
                        _ComposerAction(
                          icon: Icons.event_outlined,
                          label: 'Événement',
                          color: AppColors.orangeRed,
                          onTap: onTapEvent,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _PublishButton(onTap: onTapPublish),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Champ pilule du composeur.
///
/// C'est un vrai [TextField], pas une décoration, mais en lecture seule :
/// il reproduit le champ « Quoi de neuf ? » des fils sociaux, dont l'appui
/// n'édite pas sur place mais ouvre l'interface de création complète
/// ([onTap]). `readOnly` conserve le rendu métrique exact d'un champ de
/// saisie (hint, focus, gros texte système) tout en remontant l'appui.
class _PillField extends StatelessWidget {
  const _PillField({required this.onTap});

  final VoidCallback onTap;

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(100),
    borderSide: BorderSide(color: color, width: 1),
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      onTap: onTap,
      maxLines: 1,
      enableInteractiveSelection: false,
      style: const TextStyle(fontSize: 13, color: AppColors.textMedium),
      // isDense + un padding 6/14 : hauteur finale ≈ 30-32 px, cohérente
      // avec le rayon 100 (aspect pilule) exigé par la maquette.
      decoration: InputDecoration(
        hintText: 'Quoi de neuf ? Partagez une info...',
        hintMaxLines: 1,
        isDense: true,
        filled: true,
        fillColor: _pillFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        enabledBorder: _border(_pillBorder),
        focusedBorder: _border(_pillBorder),
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
      ),
    );
  }
}

/// Bouton principal « Publier » : fond bleu foncé, texte blanc, coins
/// arrondis, hauteur 28 px (la maquette autorise 24 à 28 px).
class _PublishButton extends StatelessWidget {
  const _PublishButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 28),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text(
        'Publier',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Action compacte de la rangée 2 : icône colorée + libellé.
///
/// `InkWell` + padding 8/8 : la zone tactile garde une hauteur franche
/// (~32 px) même si l'icône de 16 px paraît petite à l'écran.
class _ComposerAction extends StatelessWidget {
  const _ComposerAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
