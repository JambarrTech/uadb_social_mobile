/// Filet de régression pour le crash constaté sur appareil réel : un
/// [CustomButton] placé dans une `Row` contenant des `Spacer` est mesuré
/// en largeur infinie (une `Row` mesure ses enfants non flex sans borne).
/// Si le style du bouton impose `minimumSize` en LARGEUR infinie, la
/// contrainte transmise devient strictement `BoxConstraints(w=Infinity)`
/// → « BoxConstraints forces an infinite width ».
///
/// Le thème global utilise désormais `Size.fromHeight` (largeur non
/// minée) : le premier test verrouille le comportement sain (étirement
/// complet au parent borné, largeur fixe respectée dans une `Row` à
/// `Spacer`, zéro exception) ; le second reproduit l'ancien thème pour
/// prouver que le filet détecte réellement la contrainte invalide.
///
/// Les libellés sont volontairement courts : la police factice du
/// framework de test dessine chaque glyphe à ~1 taille de police, ce qui
/// ferait déborder des libellés réalistes pour de fausses raisons de
/// métrique, sans rapport avec les contraintes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uadb_social/core/theme/app_colors.dart';
import 'package:uadb_social/core/theme/app_theme.dart';
import 'package:uadb_social/shared/widgets/custom_button.dart';

/// Header reproduit d'après l'écran de création : `Row` avec `IconButton`,
/// deux `Spacer` centrant le titre, puis un [CustomButton] non flex —
/// la combinaison exacte qui faisait cracher le layout sur appareil.
Widget createPostHeader({
  required ThemeData theme,
  required double? buttonWidth,
}) {
  return MaterialApp(
    theme: theme,
    home: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('contrôle'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Parent borné : sans `width`, le bouton s'étire sur toute la
            // largeur (comportement qu'ancrait l'ancien `minimumSize`).
            Padding(
              padding: const EdgeInsets.all(12),
              child: CustomButton(text: 'OK', onPressed: () {}),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Fermer',
                  ),
                  const Spacer(),
                  const Text('Titre'),
                  const Spacer(),
                  CustomButton(
                    text: 'OK',
                    onPressed: () {},
                    width: buttonWidth,
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    borderRadius: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('thème sain : Row à Spacer sans contrainte invalide', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 840));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      createPostHeader(
        theme: AppTheme.lightTheme,
        // 100 px : les ~28 px du libellé factice + le padding 36 tiennent.
        buttonWidth: 100,
      ),
    );
    await tester.pumpAndSettle();

    // Le bouton sans `width` est étiré sur toute la largeur du parent
    // (360 − 2 × 12 de padding = 336).
    final stretched = tester.getRect(find.byType(ElevatedButton).first);
    expect(
      stretched.width,
      closeTo(336, 0.5),
      reason: 'CustomButton sans width : étiré au parent borné',
    );

    // Le bouton de la Row à `Spacer` garde sa largeur fixe.
    final fixed = tester.getRect(find.byType(ElevatedButton).last);
    expect(
      fixed.width,
      closeTo(100, 0.5),
      reason: 'CustomButton(width: 100) dans une Row à Spacer : largeur fixe',
    );

    expect(
      tester.takeException(),
      isNull,
      reason: 'aucune contrainte invalide à 360 px',
    );
  });

  testWidgets('contrôle négatif : minimumSize en largeur infinie crashe', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 840));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // Ancien thème (celui constaté sur appareil) + bouton SANS largeur
    // dans la Row à `Spacer` — la mesure non bornée rend `minWidth = ∞`
    // strict et doit lever l'exception, prouvant que le filet ci-dessus
    // détecte bien le cas réel.
    final legacy = AppTheme.lightTheme.copyWith(
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
    );

    await tester.pumpWidget(createPostHeader(theme: legacy, buttonWidth: null));
    await tester.pumpAndSettle();

    final exception = tester.takeException();
    // `takeException` peut renvoyer un composite (« Multiple exceptions »)
    // quand plusieurs relayouts en lèvent : l'existence d'une exception est
    // la preuve recherchée — la chaîne « infinite » figure dans le dump
    // détaillé imprimé en amont, pas dans le composite.
    expect(
      exception,
      isNotNull,
      reason:
          'l’ancien thème (largeur minimale infinie) doit être détecté '
          'par ce filet',
    );
  });
}
