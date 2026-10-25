import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uadb_social/core/providers.dart';
import 'package:uadb_social/core/services/token_store.dart';
import 'package:uadb_social/features/home/screens/home_screen.dart';

import 'helpers/test_store.dart';

void main() {
  Future<void> capture(WidgetTester tester, double width, String name) async {
    final TokenStore store = await createTestStore();
    await tester.binding.setSurfaceSize(Size(width, 840));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [tokenStoreProvider.overrideWithValue(store)],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('shots/$name.png'),
    );
  }

  testWidgets('capture 360', (t) => capture(t, 360, 'home_360'));
  testWidgets('capture 390', (t) => capture(t, 390, 'home_390'));
  testWidgets('capture 412', (t) => capture(t, 412, 'home_412'));
}
