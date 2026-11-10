import 'package:ecovision/features/history/presentation/screens/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('history starts empty and never pretends demo is real', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HistoryScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Belum ada riwayat scan'), findsOneWidget);
    expect(find.byKey(const ValueKey('historyDemoBanner')), findsNothing);
  });

  testWidgets('opting into demo shows visibly marked synthetic records', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HistoryScreen())),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('historyDemoToggle')),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('historyDemoToggle')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('historyDemoBanner')), findsOneWidget);
    expect(find.text('Belum ada riwayat scan'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('6 contoh ditemukan'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('6 contoh ditemukan'), findsOneWidget);
  });

  testWidgets('demo history can be filtered to paper', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HistoryScreen())),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('historyDemoToggle')),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('historyDemoToggle')));
    await tester.pumpAndSettle();

    final paperChip = find.byKey(const ValueKey('historyFilter_paper'));
    await tester.scrollUntilVisible(
      paperChip,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(paperChip);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('1 contoh ditemukan'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('1 contoh ditemukan'), findsOneWidget);
  });
}
