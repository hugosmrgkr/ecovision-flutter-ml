import 'package:ecovision/features/guide/presentation/screens/guide_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('guide shows the shared six-class material guidance', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: GuideScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Kenali 6 kategori sampah'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('guideCategory_cardboard')),
      findsOneWidget,
    );
    expect(find.text('Kardus'), findsOneWidget);
  });

  testWidgets('expanding a guide reveals actionable steps', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: GuideScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kardus'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Pisahkan kardus dari sampah basah'),
      findsOneWidget,
    );
  });
}
