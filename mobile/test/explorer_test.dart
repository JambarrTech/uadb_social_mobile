/// Écran Explorer : maquette riche (chips, tendance, suivre, adhésions).
library;

// Vérifie la structure demandée par la maquette : rangée de pastilles de
// filtre, publication tendance issue du fil réel, personnes avec bouton
// « Suivre », communautés avec « Rejoindre », événements avec badge de
// date — et la recherche qui filtre chaque section (publications incluses).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uadb_social/core/providers.dart';
import 'package:uadb_social/features/explore/screens/explorer_screen.dart';
import 'package:uadb_social/shared/widgets/post_card.dart';

import 'helpers/test_store.dart';

void main() {
  /// Monte l'Exploration avec un stockage en mémoire.
  ///
  /// Hauteur de surface 1600 px : sous 800 px, les sections basses
  /// (communautés, événements) sont hors de la zone construite par la
  /// ListView paresseuse et plein-bord, ce qui rendait les taps de bas de
  /// page non délivrés ; à 1600 px, tout le contenu tient dans le viewport
  /// construit. Sur appareil réel la taille est inchangée.
  Future<void> pumpExplorer(WidgetTester tester) async {
    final store = await createTestStore();

    await tester.binding.setSurfaceSize(const Size(390, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [tokenStoreProvider.overrideWithValue(store)],
        child: const MaterialApp(home: ExplorerScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Vide la file des exceptions (RenderFlex overflow etc.).
  List<Object?> drainExceptions(WidgetTester tester) {
    final errors = <Object?>[];
    Object? error;
    while ((error = tester.takeException()) != null) {
      errors.add(error);
    }
    return errors;
  }

  testWidgets('état initial : chips, tendance du fil, suivre, rejoindre, '
      'événements', (tester) async {
    await pumpExplorer(tester);

    // Pastilles de filtre.
    for (final label in [
      'Tout',
      'Personnes',
      'Publications',
      'Communautés',
      'Événements',
    ]) {
      expect(find.text(label), findsWidgets, reason: 'pastille « $label »');
    }

    // Tendance : la publication du fil, en carte interactive réelle.
    expect(find.text('Publication tendance'), findsOneWidget);
    expect(find.byType(PostCard), findsWidgets);

    // Suggérés et communautés.
    expect(find.text('Personnes suggérées'), findsOneWidget);
    expect(find.textContaining('Suivre'), findsWidgets);
    expect(find.text('Communautés populaires'), findsOneWidget);
    expect(find.text('Rejoindre'), findsNWidgets(3));
    expect(find.textContaining('Journées Portes Ouvertes'), findsOneWidget);
    expect(find.textContaining('Hackathon IA 2025'), findsOneWidget);

    // La bannière de démonstration encombrante a disparu.
    expect(find.textContaining('Contenu de démonstration'), findsNothing);

    expect(drainExceptions(tester), isEmpty);
  });

  testWidgets('« hackathon » remonte la publication correspondante', (
    tester,
  ) async {
    await pumpExplorer(tester);

    await tester.enterText(find.byType(TextField), 'hackathon');
    await tester.pumpAndSettle();

    expect(find.textContaining('hackathon de Dakar'), findsWidgets);
    // Les sections sans correspondance annoncent leur état vide.
    expect(
      find.textContaining('aucune personne ne correspond'),
      findsOneWidget,
    );
    // L'événement « Hackathon IA 2025 · Agriculture » CORRESPOND à la
    // requête : sa tuile reste affichée, pas d'état vide événements.
    expect(find.textContaining('Hackathon IA 2025'), findsOneWidget);
    expect(find.textContaining('aucun événement ne correspond'), findsNothing);

    expect(drainExceptions(tester), isEmpty);
  });

  testWidgets('la pastille « Publications » isole la liste des publications', (
    tester,
  ) async {
    await pumpExplorer(tester);

    await tester.tap(find.text('Publications'));
    await tester.pumpAndSettle();

    // Plus de sections personnes/communautés/événements.
    expect(find.text('Rejoindre'), findsNothing);
    expect(find.textContaining('Suivre'), findsNothing);
    // Toutes les publications du fil sont listées (démonstration: 3).
    expect(find.byType(PostCard), findsNWidgets(3));
    // Les pastilles restent affichées en haut.
    expect(find.text('Tout'), findsOneWidget);

    expect(drainExceptions(tester), isEmpty);
  });

  testWidgets('Suivre bascule en « Suivi » sans détruire la ligne', (
    tester,
  ) async {
    await pumpExplorer(tester);

    // La rangée de personnes est bas de page sous la tendance : on la fait
    // entrer dans la fenêtre avant de pointer dessus.
    await tester.ensureVisible(find.text('Suivre').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Suivre').first);
    await tester.pumpAndSettle();

    expect(find.text('Suivi'), findsOneWidget);
    expect(
      find.text('Suivre'),
      findsWidgets,
      reason: 'les autres personnes restent à suivre',
    );

    expect(drainExceptions(tester), isEmpty);
  });

  testWidgets('Rejoindre bascule en « Membre »', (tester) async {
    await pumpExplorer(tester);

    await tester.ensureVisible(find.text('Rejoindre').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rejoindre').first);
    await tester.pumpAndSettle();

    expect(find.text('Membre'), findsOneWidget);
    expect(find.text('Rejoindre'), findsNWidgets(2));

    expect(drainExceptions(tester), isEmpty);
  });
}
