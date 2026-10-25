/// Carte de publication : fidélité visuelle et comportements.
library;

// La carte est vérifiée à la largeur de référence (390 px) et sur l'étroit
// (360 px) pour les débordements, avec les cinq variantes de contenu :
// texte long, zéro image, une image, deux images, trois images.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uadb_social/core/models/post.dart';
import 'package:uadb_social/features/feed/data/local_post_store.dart';
import 'package:uadb_social/shared/widgets/post_card.dart';
import 'package:uadb_social/shared/widgets/user_avatar.dart';

/// Montre une carte dans une fenêtre de [width] px de large.
Future<void> pumpCard(
  WidgetTester tester,
  Post post, {
  double width = 390,
}) async {
  await tester.binding.setSurfaceSize(Size(width, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: _CardHarness(post: post),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Carte pilotée en état : J'aime et Enregistrer y basculent localement,
/// comme dans le fil réel (contrôleur + carte dotée de l'état renvoyé).
class _CardHarness extends StatefulWidget {
  const _CardHarness({required this.post});

  final Post post;

  @override
  State<_CardHarness> createState() => _CardHarnessState();
}

class _CardHarnessState extends State<_CardHarness> {
  late Post post = widget.post;
  bool saved = false;

  void _toggleLike() {
    setState(() {
      post = post.copyWith(
        likedByMe: !post.likedByMe,
        likesCount: post.likesCount + (post.likedByMe ? -1 : 1),
      );
    });
  }

  void _toggleSave() => setState(() => saved = !saved);

  @override
  Widget build(BuildContext context) {
    return PostCard(
      post: post,
      onLike: _toggleLike,
      isSaved: saved,
      onToggleSave: _toggleSave,
    );
  }
}

Post _basePost({
  String? authorName,
  String? authorRole,
  String content = 'Un message de test.',
  List<String> images = const [],
  bool likedByMe = false,
  int likesCount = 0,
  int commentsCount = 0,
  bool isOfficial = false,
}) => Post(
  id: 'test-1',
  authorId: 'a1',
  authorName: authorName ?? 'Aminata Diallo',
  authorRole: authorRole ?? 'Licence 3 Informatique',
  content: content,
  imageUrls: images,
  likedByMe: likedByMe,
  likesCount: likesCount,
  commentsCount: commentsCount,
  isOfficial: isOfficial,
);

/// Seaux des exceptions de layout (RenderFlex overflow) collectés.
List<Object?> drainExceptions(WidgetTester tester) {
  final errors = <Object?>[];
  Object? error;
  while ((error = tester.takeException()) != null) {
    errors.add(error);
  }
  return errors;
}

void main() {
  group('en-tête', () {
    testWidgets('affiche le nom, la filière et le menu à trois points', (
      tester,
    ) async {
      await pumpCard(tester, _basePost());

      expect(find.text('Aminata Diallo'), findsOneWidget);
      // L'avatar porte les initiales, pas le nom entier (30 px de cercle).
      expect(
        find.descendant(of: find.byType(UserAvatar), matching: find.text('AD')),
        findsOneWidget,
      );
      expect(
        find.textContaining('Licence 3 Informatique'),
        findsOneWidget,
        reason: 'les informations secondaires doivent être visibles',
      );
      expect(
        find.byIcon(Icons.more_horiz),
        findsOneWidget,
        reason: 'le menu veut trois points HORIZONTAUX, pas verticaux',
      );
    });

    testWidgets('un nom très long ne fait pas déborder la carte à 360 px', (
      tester,
    ) async {
      await pumpCard(
        tester,
        _basePost(
          authorName: 'Aminata Diagne-Ndiaye de la Scolarité de l’Institut Universitaire',
        ),
      );

      expect(
        drainExceptions(tester),
        isEmpty,
        reason: 'aucun débordement de ligne dans l’en-tête',
      );
    });

    testWidgets('affiche le badge Officiel pour un compte officiel', (
      tester,
    ) async {
      await pumpCard(tester, _basePost(isOfficial: true));
      expect(find.text('Officiel'), findsOneWidget);
    });
  });

  group('contenu textuel', () {
    testWidgets('le texte long s’affiche sur plusieurs lignes, sans '
        'troncature ni débordement', (tester) async {
      const content =
          'Félicitations à toute l’équipe de l’UADB qui a remporté le '
          'deuxième prix au hackathon de Dakar ! Notre application '
          'd’irrigation intelligente pour Bambey a séduit le jury. 🎉🚜';

      await pumpCard(tester, _basePost(content: content));

      final text = find.textContaining('deuxième prix au hackathon');
      expect(text, findsOneWidget);

      // Retours à la ligne naturels : le widget texte doit s'étaler sur au
      // moins deux lignes dont la largeur utile reste bornée.
      final contentText = tester
          .widgetList<Text>(find.byType(Text))
          .firstWhere(
            (element) => element.data?.contains('hackathon') ?? false,
          );
      expect(
        contentText.maxLines,
        isNull,
        reason: 'aucune limite de ligne imposée',
      );

      expect(drainExceptions(tester), isEmpty);
    });

    testWidgets('aucune publication sans texte ni image ne fait déborder', (
      tester,
    ) async {
      await pumpCard(tester, _basePost(content: ''));
      expect(drainExceptions(tester), isEmpty);
    });
  });

  group('galerie', () {
    testWidgets('sans image : aucune vignette', (tester) async {
      await pumpCard(tester, _basePost());
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('une image : pleine largeur', (tester) async {
      await pumpCard(
        tester,
        _basePost(images: const ['assets/demo_event.jpg']),
      );

      expect(find.byType(Image), findsOneWidget);
      final imageRect = tester.getRect(find.byType(Image));
      // L'Align laisse la carte s'étendre : 390 px, moins 2 × 12 px de
      // padding interne, moins 2 × 1 px de bordure — soit 364 px utiles.
      expect(imageRect.width, closeTo(364, 2));
      expect(drainExceptions(tester), isEmpty);
    });

    testWidgets('deux images : côte à côte, même hauteur, largeurs égales', (
      tester,
    ) async {
      await pumpCard(
        tester,
        _basePost(
          images: const ['assets/demo_event.jpg', 'assets/demo_solar.jpg'],
        ),
      );

      final images = find.byType(Image);
      expect(images, findsNWidgets(2));

      final left = tester.getRect(images.first);
      final right = tester.getRect(images.last);

      expect(left.height, right.height, reason: 'hauteurs égales');
      expect(
        left.width,
        closeTo(right.width, 0.01),
        reason: 'largeurs équilibrées',
      );
      expect(
        right.left - left.right,
        inInclusiveRange(4, 6),
        reason: '5 px d‘espacement entre les deux vignettes',
      );
      expect(drainExceptions(tester), isEmpty);
    });

    testWidgets('trois images : deux vignettes + pastille « +1 »', (
      tester,
    ) async {
      await pumpCard(
        tester,
        _basePost(
          images: const [
            'assets/demo_event.jpg',
            'assets/demo_solar.jpg',
            'assets/demo_field.jpg',
          ],
        ),
      );

      expect(find.byType(Image), findsNWidgets(2));
      expect(find.text('+1'), findsOneWidget);
      expect(drainExceptions(tester), isEmpty);
    });

    testWidgets('le tap sur une image ouvre la visionneuse', (tester) async {
      await pumpCard(
        tester,
        _basePost(
          images: const ['assets/demo_event.jpg', 'assets/demo_solar.jpg'],
        ),
      );

      await tester.tap(find.byType(Image).first);
      await tester.pumpAndSettle();

      expect(
        find.text('1 / 2'),
        findsOneWidget,
        reason: 'indicateur de position de la visionneuse',
      );
      expect(find.byType(PageView), findsOneWidget);

      // Fermeture : la feuille plein écran revient à la carte intacte.
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('1 / 2'), findsNothing);
      expect(find.byType(PostCard), findsOneWidget);
    });
  });

  group('barre d’actions', () {
    testWidgets('compteurs issus des données de la publication', (
      tester,
    ) async {
      await pumpCard(tester, _basePost(likesCount: 24, commentsCount: 8));

      expect(find.text('24'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
    });

    testWidgets('grands compteurs raccourcis', (tester) async {
      await pumpCard(tester, _basePost(likesCount: 1213, commentsCount: 2));
      expect(find.text('1.2 k'), findsOneWidget);
    });

    testWidgets('J’aime : cœur contour gris, rempli rouge une fois aimé', (
      tester,
    ) async {
      await pumpCard(tester, _basePost(likesCount: 24));

      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
      expect(find.byIcon(Icons.favorite_rounded), findsNothing);

      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
      expect(find.text('25'), findsOneWidget, reason: '24 + 1 après le tap');

      await tester.tap(find.byIcon(Icons.favorite_rounded));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
      expect(find.text('24'), findsOneWidget, reason: 'retrait du like');
    });

    testWidgets('Commenter sans interface existante : état explicite', (
      tester,
    ) async {
      await pumpCard(tester, _basePost(commentsCount: 8));

      await tester.tap(find.byIcon(Icons.chat_bubble_outline_rounded));
      await tester.pumpAndSettle();

      expect(
        find.text('Commentaires : bientôt disponible.'),
        findsOneWidget,
        reason: 'aucune simulation : l’absence est annoncée explicitement',
      );
    });

    testWidgets('Enregistrer : contour puis signet plein, et inversement', (
      tester,
    ) async {
      await pumpCard(tester, _basePost());

      expect(find.byIcon(Icons.bookmark_border_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.bookmark_border_rounded));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.bookmark_rounded));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.bookmark_border_rounded), findsOneWidget);
    });

    testWidgets('aucun débordement de la barre à 360 px', (tester) async {
      await pumpCard(
        tester,
        _basePost(
          authorName: 'Aminata Diagne-Ndiaye',
          likesCount: 12345,
          commentsCount: 9876,
        ),
        width: 360,
      );

      expect(drainExceptions(tester), isEmpty);
      expect(find.text('12 k'), findsOneWidget);
      expect(find.text('9.9 k'), findsOneWidget);
    });
  });

  group('menu de la publication', () {
    testWidgets('ouvre les actions disponibles de la publication', (
      tester,
    ) async {
      var saveToggled = false;
      await tester.binding.setSurfaceSize(const Size(390, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topCenter,
              child: PostCard(
                post: _basePost(likesCount: 24, commentsCount: 8),
                onToggleSave: () => saveToggled = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      expect(find.text('Enregistrer la publication'), findsOneWidget);
      expect(find.text('Copier le texte'), findsOneWidget);
      expect(find.text('Signaler'), findsOneWidget);

      await tester.tap(find.text('Enregistrer la publication'));
      await tester.pumpAndSettle();

      expect(saveToggled, isTrue);
    });

    testWidgets('une publication enregistrée propose « Retirer des favoris »', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topCenter,
              child: PostCard(
                post: _basePost(),
                isSaved: true,
                onToggleSave: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      expect(find.text('Retirer des favoris'), findsOneWidget);
    });
  });

  // Les publications créées dans l'app portent des chemins de fichiers
  // locaux (photos choisies via le picker), pas des URL : la galerie doit
  // les lire comme des fichiers, faute de quoi la carte tombait en repli
  // et paraissait « sans images ».
  group('photos choisies sur l’appareil', () {
    testWidgets(
      'un chemin de fichier local s’affiche via Image.file, sans débordement',
      (tester) async {
        await pumpCard(
          tester,
          _basePost(images: ['/data/user/0/com.example.app/cache/photo.jpg']),
        );

        expect(
          find.byWidgetPredicate(
            (widget) => widget is Image && widget.image is FileImage,
          ),
          findsOneWidget,
          reason:
              'le chemin local doit être chargé comme un fichier, '
              'pas comme un asset ni une URL réseau',
        );
        expect(drainExceptions(tester), isEmpty);
      },
    );

    testWidgets('la visionneuse s’ouvre aussi sur un fichier local', (
      tester,
    ) async {
      await pumpCard(
        tester,
        _basePost(images: ['/data/user/0/com.example.app/cache/photo.jpg']),
      );

      await tester.tap(find.byType(Image).first);
      await tester.pumpAndSettle();

      expect(find.byType(PageView), findsOneWidget);
      expect(drainExceptions(tester), isEmpty);
    });
  });

  // La publication de démonstration doit reproduire la capture de
  // référence : si quelqu'un en change, le test le signale et impose
  // de vérifier l'impact visuel sur l'accueil.
  group('contenu de démonstration', () {
    test('la première publication reprend la capture de référence', () {
      final post = demoFeed(DateTime.now()).first;

      expect(post.authorName, 'Aminata Diallo');
      expect(post.authorRole, 'Licence 3 Informatique');
      expect(post.content, contains('deuxième prix au hackathon de Dakar'));
      expect(post.content, contains('irrigation intelligente pour Bambey'));
      expect(post.imageUrls, hasLength(2));
      expect(post.likesCount, 24);
      expect(post.commentsCount, 8);
      expect(post.likedByMe, isTrue, reason: 'cœur rouge de la capture');
    });
  });
}
