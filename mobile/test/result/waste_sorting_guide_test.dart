import 'package:ecovision/features/result/domain/waste_sorting_guide.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all six model labels have a matching localized sorting guide', () {
    expect(WasteSortingGuide.labels, [
      'cardboard',
      'glass',
      'metal',
      'paper',
      'plastic',
      'trash',
    ]);

    for (final label in WasteSortingGuide.labels) {
      final guide = WasteSortingGuide.fromLabel(label);
      expect(guide.label, label);
      expect(guide.name, isNotEmpty);
      expect(guide.summary, isNotEmpty);
      expect(guide.steps, isNotEmpty);
    }
  });

  test('unknown label uses a safe fallback rather than a wrong category', () {
    final guide = WasteSortingGuide.fromLabel('unknown-label');
    expect(guide.label, 'unknown');
    expect(guide.name, 'Tidak diketahui');
  });
}
