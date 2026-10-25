/// Barre de recherche de l'Exploration : résultats sur les données réelles.
library;

// La recherche doit filtrer les PUBLICATIONS du fil (contenu réel), en plus
// des entrées de démonstration : taper « hackathon » fait remonter la
// publication de démonstration correspondante, ouvrable et interagissable
// comme sur l'accueil.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uadb_social/core/providers.dart';
import 'package:uadb_social/features/explore/screens/explorer_screen.dart';
import 'package:uadb_social/shared/widgets/post_card.dart';

import 'helpers/test_store.dart';

void main() {
  /// Monte l'Exploration à 390 px avec un stockage en mémoire.
  Future<void> pumpExplorer(WidgetTester tester) async {
    final store = await createTestStore();

    await tester.binding.setSurfaceSize(const Size(390, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [tokenStoreProvider.overrideWithValue(store)],
        child: const MaterialApp(home: ExplorerScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('la barre de recherche est présente et sans requête aucune '
      'section « Publications »', (tester) async {
    await pumpExplorer(tester);

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Publications'), findsNothing);
    // Les sections de démonstration sont visibles à l'état initial.
    expect(find.text('Tendances'), findsOneWidget);
  });

  testWidgets('« hackathon » remonte les publications correspondantes', (
    tester,
  ) async {
    await pumpExplorer(tester);

    await tester.enterText(find.byType(TextField), 'hackathon');
    await tester.pumpAndSettle();

    expect(find.text('Publications'), findsOneWidget);
    // La publication de démonstration du fil correspond au mot-clé.
    expect(find.textContaining('hackathon de Dakar'), findsWidgets);
    // Les résultats sont des cartes interagissables, pas des libellés figés.
    expect(find.byType(PostCard), findsWidgets);
  });

  testWidgets('une requête sans correspondance affiche un état vide clair', (
    tester,
  ) async {
    await pumpExplorer(tester);

    await tester.enterText(find.byType(TextField), 'inconnuxyz');
    await tester.pumpAndSettle();

    expect(
      find.textContaining('aucune publication ne correspond'),
      findsOneWidget,
    );
    expect(find.byType(PostCard), findsNothing);
  });
}
