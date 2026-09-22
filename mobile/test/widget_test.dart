import 'package:flutter_test/flutter_test.dart';
import 'package:uadb_social/app.dart';

void main() {
  testWidgets('affiche le splash UADB Social', (WidgetTester tester) async {
    await tester.pumpWidget(const UadbSocialApp());

    // Le splash affiche le slogan (et non le mot "UADB", présent seulement
    // sous forme d'image du logo).
    expect(find.text('Le réseau de notre communauté.'), findsOneWidget);

    // Vérifie qu'aucune erreur d'asset n'est remontée (logo.jpeg présent).
    expect(tester.takeException(), isNull);
  });
}
