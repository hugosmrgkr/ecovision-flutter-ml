import 'package:ecovision/features/history/data/repositories/demo_history_repository.dart';
import 'package:ecovision/features/history/presentation/providers/history_providers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('demo history contains exactly six supported categories', () {
    final entries = const DemoHistoryRepository().getDemoEntries();
    expect(entries.length, 6);
    expect(entries.map((e) => e.label).toSet(), {
      'cardboard',
      'glass',
      'metal',
      'paper',
      'plastic',
      'trash',
    });
    expect(
      entries.every((e) => e.confidence >= 0 && e.confidence <= 1),
      isTrue,
    );
  });

  test('category filtering uses the stable model label', () {
    final entries = const DemoHistoryRepository().getDemoEntries();
    final filtered = filterDemoHistory(entries, category: 'paper');
    expect(filtered.length, 1);
    expect(filtered.single.label, 'paper');
  });

  test('search matches Indonesian category names', () {
    final entries = const DemoHistoryRepository().getDemoEntries();
    expect(filterDemoHistory(entries, query: 'kertas').single.label, 'paper');
    expect(filterDemoHistory(entries, query: 'tidak-ada'), isEmpty);
  });
}
