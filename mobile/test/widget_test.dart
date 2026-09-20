import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app.dart';

void main() {
  testWidgets('affiche le splash UADB Social', (WidgetTester tester) async {
    await tester.pumpWidget(const UadbSocialApp());
    expect(find.text('UADB'), findsOneWidget);
    expect(find.text('Le réseau de votre communauté.'), findsOneWidget);
  });
}
