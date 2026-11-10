import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/demo_history_repository.dart';
import '../../domain/entities/scan_history_entry.dart';
import '../../domain/repositories/history_repository.dart';

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => const DemoHistoryRepository(),
);

/// Demo-only data. This provider is not the user's history store.
final demoHistoryProvider = Provider<List<ScanHistoryEntry>>(
  (ref) => ref.watch(historyRepositoryProvider).getDemoEntries(),
);

List<ScanHistoryEntry> filterDemoHistory(
  List<ScanHistoryEntry> entries, {
  String? category,
  String query = '',
}) {
  final needle = query.trim().toLowerCase();
  return entries
      .where((entry) {
        if (category != null && entry.label != category) return false;
        if (needle.isEmpty) return true;
        // Both the stable ML class name and localized category name are searchable.
        const names = {
          'cardboard': 'kardus karton cardboard',
          'glass': 'kaca glass',
          'metal': 'logam metal',
          'paper': 'kertas paper',
          'plastic': 'plastik plastic',
          'trash': 'sampah residu trash',
        };
        return (names[entry.label] ?? entry.label).contains(needle);
      })
      .toList(growable: false);
}
