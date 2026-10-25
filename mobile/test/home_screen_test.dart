/// Contrôle de l'écran d'accueil sur les largeurs cibles de la maquette.
library;

// Le fil est vérifié à 360, 390 et 412 px — les trois largeurs imposées par
// la maquette — parce que la barre d'actions du composeur (« Photo »,
// « Vidéo », « Événement » + « Publier ») est l'endroit le plus serré de
// l'écran : c'est elle qui débordait réellement de 60 px sur l'appareil de
// test avant correction.
//
// On vérifie aussi que le fil se défile jusqu'à la dernière publication et
// qu'elle reste au-dessus de la barre de navigation inférieure (52 px +
// marge), celle-ci étant superposée au contenu par le shell.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uadb_social/core/providers.dart';
import 'package:uadb_social/core/services/token_store.dart';
import 'package:uadb_social/features/home/screens/home_screen.dart';
import 'package:uadb_social/shared/widgets/post_card.dart';
import 'package:uadb_social/shared/widgets/user_avatar.dart';

import 'helpers/test_store.dart';

/// Largeur logique de l'écran, en pixels.
const _screenHeight = 800.0;

/// Hauteur de la barre de navigation inférieure, sous laquelle aucun contenu
/// ne doit passer (cf. `BottomNavBar` : 52 px + padding de 8 px).
const _bottomNavClearance = 60.0;

void main() {
  /// Monte l'accueil sur une fenêtre de [width] px de large.
  ///
  /// `tokenStoreProvider` lève par défaut (il est surchargé dans `main()`), ce
  /// qui oblige à fournir un store réel adossé à des préférences en mémoire.
  Future<void> pumpHome(WidgetTester tester, double width) async {
    final TokenStore store = await createTestStore();

    await tester.binding.setSurfaceSize(Size(width, _screenHeight));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [tokenStoreProvider.overrideWithValue(store)],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Vide la file des exceptions collectées par le binding.
  ///
  /// Un débordement de `RenderFlex` n'est pas levé : il est rapporté à
  /// `FlutterError.onError` et reste pending jusqu'à la fin du test. Il faut
  /// donc le vider explicitement pour le comparer à `isEmpty`.
  List<Object?> drainExceptions(WidgetTester tester) {
    final errors = <Object?>[];
    Object? error;
    while ((error = tester.takeException()) != null) {
      errors.add(error);
    }
    return errors;
  }

  /// Fait défiler le fil jusqu'à ce qu'il n'ait plus de défilement possible.
  ///
  /// Le fil est le seul `[ListView]` de l'écran : on cible son `[Scrollable]`
  /// explicitement pour ne pas tomber sur le `Scrollable` horizontal du champ
  /// du composeur, lecture seule mais défilable lui aussi.
  Future<void> scrollToEnd(WidgetTester tester) async {
    final scrollable = find.descendant(
      of: find.byType(ListView),
      matching: find.byType(Scrollable),
    );
    for (var i = 0; i < 60; i++) {
      final position = tester.state<ScrollableState>(scrollable).position;
      final before = position.pixels;
      if (position.atEdge && before > 0) break;

      await tester.drag(scrollable, const Offset(0, -300));
      await tester.pumpAndSettle();

      final after = tester.state<ScrollableState>(scrollable).position.pixels;
      if ((after - before).abs() < 0.5) break;
    }
  }

  group('accueil — largeurs cibles', () {
    for (final width in [360.0, 390.0, 412.0]) {
      testWidgets('${width.toInt()} px : aucun débordement', (tester) async {
        await pumpHome(tester, width);

        expect(
          drainExceptions(tester),
          isEmpty,
          reason: 'aucun RenderFlex overflow à ${width.toInt()} px',
        );

        // Marge horizontale du fil : 12 px de chaque côté, identique pour
        // chaque carte (exigence de la maquette : « marges horizontales
        // identiques entre les cartes »).
        final card = tester.getRect(find.byType(PostCard).first);
        expect(
          card.left,
          greaterThanOrEqualTo(12),
          reason: 'marge gauche de 12 px à ${width.toInt()} px',
        );
        expect(
          width - card.right,
          greaterThanOrEqualTo(12),
          reason: 'marge droite de 12 px à ${width.toInt()} px',
        );
      });
    }
  });

  group('accueil — contenu', () {
    testWidgets('affiche le composeur et ses quatre contrôles', (tester) async {
      await pumpHome(tester, 390);

      expect(find.text('Quoi de neuf ? Partagez une info...'), findsOneWidget);
      for (final label in ['Photo', 'Vidéo', 'Événement', 'Publier']) {
        expect(find.text(label), findsOneWidget, reason: '« $label »');
      }

      // Le composeur et les publications partagent la même gouttière : les
      // avatars de la première carte de publication doivent être à
      // l'aplomb de celui du composeur.
      final composerAvatarLeft = tester
          .getTopLeft(find.byType(UserAvatar).first)
          .dx;
      final cardAvatarLeft = tester
          .getTopLeft(
            find.descendant(
              of: find.byType(PostCard).first,
              matching: find.byType(UserAvatar),
            ),
          )
          .dx;
      expect(
        cardAvatarLeft,
        closeTo(composerAvatarLeft, 1.0),
        reason:
            'composeur et publications doivent être alignés sur une '
            'même grille gauche',
      );

      expect(drainExceptions(tester), isEmpty);
    });

    testWidgets('affiche les trois publications de démonstration', (
      tester,
    ) async {
      await pumpHome(tester, 412);

      // Une `ListView` ne monte que les cartes entrées dans son étendue de
      // cache : il faut donc parcourir le fil pour rencontrer les trois
      // auteurs, certains quittant l'arbre une fois dépassés.
      const authors = [
        'Aminata Diallo',
        'Direction Scolarité',
        'Moussa Ndiaye',
      ];
      final seen = <String>{};
      final scrollable = find.descendant(
        // Cibler le fil (seul `ListView`) et non le `Scrollable` horizontal
        // du champ du composeur.
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      );

      for (var i = 0; i < 60 && seen.length < authors.length; i++) {
        for (final author in authors) {
          if (find.text(author).evaluate().isNotEmpty) seen.add(author);
        }
        if (seen.length == authors.length) break;

        await tester.drag(scrollable, const Offset(0, -300));
        await tester.pumpAndSettle();
      }

      expect(
        seen,
        containsAll(authors),
        reason:
            'les trois publications de démonstration doivent être '
            'rencontrées en défilant le fil',
      );
      expect(drainExceptions(tester), isEmpty);
    });

    testWidgets('défile jusqu’à la dernière publication sans être masqué par '
        'la navigation', (tester) async {
      await pumpHome(tester, 390);

      await scrollToEnd(tester);

      final screenHeight = tester.getSize(find.byType(MaterialApp)).height;
      final lastRect = tester.getRect(find.byType(PostCard).last);

      expect(
        lastRect.bottom,
        lessThanOrEqualTo(screenHeight),
        reason:
            'la dernière publication doit être entièrement visible '
            'une fois le fil défilé jusqu’au bout',
      );
      expect(
        lastRect.bottom,
        lessThanOrEqualTo(screenHeight - _bottomNavClearance),
        reason:
            'la dernière publication doit rester au-dessus de la barre '
            'de navigation inférieure ($_bottomNavClearance px)',
      );
      expect(drainExceptions(tester), isEmpty);
    });
  });

  group('accueil — validité du contrôle', () {
    testWidgets('un débordement est bien détecté', (tester) async {
      // Contrôle négatif : sans lui, les tests ci-dessus pourraient passer
      // pour la simple raison que la détection ne remonterait rien.
      await tester.binding.setSurfaceSize(const Size(360, _screenHeight));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [SizedBox(width: 600, child: Text('trop large'))],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        drainExceptions(tester),
        isNotEmpty,
        reason: 'un Row de 600 px dans une fenêtre de 360 px doit déborder',
      );
    });
  });
}
