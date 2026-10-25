import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/demo_notice.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/post_card.dart';
import '../../../shared/widgets/post_composer_card.dart';
import '../../../shared/widgets/responsive.dart';
import '../../auth/state/auth_controller.dart';
import '../../feed/state/feed_controller.dart';
import '../../feed/state/saved_posts_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(feedProvider);
    final user = ref.watch(currentUserProvider);
    final isDemoOnly = ref.watch(feedProvider.notifier).isDemoOnly;
    final savedIds = ref.watch(savedIdsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundAuth,
      body: Column(
        children: [
          const SafeArea(bottom: false, child: _HomeHeader()),
          // Composeur épinglé sous le trait du header : pas de marge
          // superflue entre les deux (8 px de respiration seulement), les
          // 12 px latéraux sont la gouttière commune du fil.
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: PostComposerCard(
              displayName: user.fullName,
              avatarUrl: user.avatarUrl,
              initials: user.initials,
              // Un vrai flux par contrôle, réutilisant ce qui existe déjà :
              // - le champ et « Publier » ouvrent l'écran de création
              //   (validation du contenu incluse) ;
              // - « Photo » ouvre ce même écran puis déclenche immédiatement
              //   le sélecteur d'images du projet ;
              // - « Vidéo » et « Événement » n'ont pas d'équivalent côté
              //   données (aucune vidéo ni fiche événement dans le modèle
              //   Post) : état explicite « bientôt disponible », même
              //   message que les options de l'écran de création.
              onTapField: () => context.pushNamed('create-post'),
              onTapPhoto: () => context.pushNamed(
                'create-post',
                extra: {'openImagePicker': true},
              ),
              onTapVideo: () => showAppSnackBar(
                context,
                'Vidéo : bientôt disponible.',
                isError: true,
              ),
              onTapEvent: () => showAppSnackBar(
                context,
                'Événement : bientôt disponible.',
                isError: true,
              ),
              onTapPublish: () => context.pushNamed('create-post'),
            ),
          ),
          Expanded(
            child: posts.isEmpty
                ? _Fill(
                    child: EmptyView(
                      icon: Icons.article_outlined,
                      title: 'Aucune publication',
                      subtitle:
                          'Le fil est vide pour le moment. Soyez la '
                          'première personne à partager quelque chose.',
                      action: CustomButton(
                        text: 'Publier',
                        width: 180,
                        height: 44,
                        borderRadius: 22,
                        onPressed: () => context.pushNamed('create-post'),
                      ),
                    ),
                  )
                : Center(
                    // Gouttière explicite plutôt qu'`AppPage` : celui-ci
                    // n'applique sa marge horizontale que si
                    // `MediaQuery.sizeOf(context).width < 600`, or ce chiffre
                    // ne reflète pas toujours la fenêtre réellement rendue
                    // (mesuré à 800 px pour une surface de 390 px). Le fil
                    // dépend donc de rien d'autre que ses propres gouttières,
                    // identiques et constantes sur téléphone.
                    // Sur écran large, la colonne reste lisible mais
                    // plafonnée ; sur téléphone, la contrainte est sans
                    // effet car la fenêtre est plus étroite.
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: ContentWidth.feed,
                      ),
                      child: ListView(
                        // 12 px de gouttière gauche et droite pour toutes
                        // les cartes, 10 px de départ, puis 80 px pour que
                        // la dernière publication ne repose jamais sous la
                        // barre de navigation inférieure (52 px + marge).
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 80),
                        children: [
                          if (isDemoOnly) ...[
                            const SizedBox(height: 10),
                            const DemoNotice(
                              message:
                                  'Contenu de démonstration : aucun serveur '
                                  'UADB Social n’est encore branché. Les '
                                  'publications que vous créez sont bien '
                                  'enregistrées sur l’appareil.',
                            ),
                          ],
                          const SizedBox(height: 10),
                          for (final post in posts) ...[
                            PostCard(
                              post: post,
                              onLike: () => ref
                                  .read(feedProvider.notifier)
                                  .toggleLike(post.id),
                              onShare: () => ref
                                  .read(feedProvider.notifier)
                                  .share(post.id),
                              // Favoris : état lu dans le contrôleur
                              // persistant, bascule confiée à la carte.
                              isSaved: savedIds.contains(post.id),
                              onToggleSave: () => ref
                                  .read(savedIdsProvider.notifier)
                                  .toggle(post.id),
                            ),
                            const SizedBox(height: 10),
                          ],
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Remplit la hauteur disponible tout en restant défilable, afin qu'un écran
/// vide occupe bien la page.
class _Fill extends StatelessWidget {
  const _Fill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: child,
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
            child: Row(
              children: [
                const Expanded(child: _BrandLogo()),
                Stack(
                  children: [
                    IconButton(
                      onPressed: () => showAppSnackBar(
                        context,
                        'Aucune nouvelle notification.',
                      ),
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        size: 26,
                        color: AppColors.primaryBlue,
                      ),
                      tooltip: 'Notifications',
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 42,
                        minHeight: 42,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(height: 2, color: AppColors.primaryBlue),
        ],
      ),
    );
  }
}

/// Logo officiel « UADB SOCIAL » de l'en-tête.
///
/// L'image a été rognée sur son contenu utile (ratio 4,33:1) : les marges
/// transparentes d'origine occupaient 35 % de la largeur et 50 % de la hauteur,
/// ce qui rendait le logo minuscule à l'écran. Le fichier est produit en
/// 572x132, soit 3x la taille d'affichage, pour rester net sur écran dense.
///
/// Dimensionnement : la hauteur pilote (le logo est panoramique), et
/// `BoxFit.contain` garantit qu'il n'est jamais déformé ni coupé.
class _BrandLogo extends StatelessWidget {
  const _BrandLogo();

  static const String _assetPath = 'assets/branding/uadb_social_logo.png';

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 240, maxHeight: 48),
        child: Image.asset(
          _assetPath,
          height: 48,
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
          errorBuilder: (context, error, stackTrace) => const _TextMark(),
        ),
      ),
    );
  }
}

/// Repli textuel, utilisé tant que l'image du logo n'est pas dans le projet.
class _TextMark extends StatelessWidget {
  const _TextMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.officialBadge,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: const Text(
            'U',
            style: TextStyle(
              fontFamily: AppTextStyles.interFont,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            'UADB SOCIAL',
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.headerTitle.copyWith(fontSize: 15),
          ),
        ),
      ],
    );
  }
}
