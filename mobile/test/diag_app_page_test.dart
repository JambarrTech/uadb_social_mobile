import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uadb_social/shared/widgets/responsive.dart';

void main() {
  testWidgets('diagnostic AppPage', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 840));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const key = Key('probe');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppPage(
            scrollable: false,
            maxWidth: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            verticalPadding: 0,
            child: SizedBox(
              width: double.infinity,
              child: Container(key: key, height: 50, color: Colors.red),
            ),
          ),
        ),
      ),
    );

    final element = tester.element(find.byKey(key));
    final media = MediaQuery.of(element);
    final rect = tester.getRect(find.byKey(key));

    // ignore: avoid_print
    print(
      'MEDIA width=${media.size.width} '
      'isCompact=${Breakpoints.isCompact(element)}',
    );
    // ignore: avoid_print
    print('PROBE rect=$rect');
  });
}
