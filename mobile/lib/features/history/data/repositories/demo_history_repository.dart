import '../../domain/entities/scan_history_entry.dart';
import '../../domain/repositories/history_repository.dart';

/// Fixed example records: no actual images, inference, or storage.
class DemoHistoryRepository implements HistoryRepository {
  const DemoHistoryRepository();

  @override
  List<ScanHistoryEntry> getDemoEntries() => [
    ScanHistoryEntry(
      id: 'demo-cardboard',
      label: 'cardboard',
      timestamp: DateTime(2026, 11, 1, 10, 25),
      confidence: 0.95,
    ),
    ScanHistoryEntry(
      id: 'demo-glass',
      label: 'glass',
      timestamp: DateTime(2026, 11, 1, 9, 40),
      confidence: 0.93,
    ),
    ScanHistoryEntry(
      id: 'demo-metal',
      label: 'metal',
      timestamp: DateTime(2026, 10, 31, 16, 20),
      confidence: 0.91,
    ),
    ScanHistoryEntry(
      id: 'demo-paper',
      label: 'paper',
      timestamp: DateTime(2026, 10, 31, 14, 10),
      confidence: 0.88,
    ),
    ScanHistoryEntry(
      id: 'demo-plastic',
      label: 'plastic',
      timestamp: DateTime(2026, 10, 30, 11, 45),
      confidence: 0.92,
    ),
    ScanHistoryEntry(
      id: 'demo-trash',
      label: 'trash',
      timestamp: DateTime(2026, 10, 30, 8, 5),
      confidence: 0.87,
    ),
  ];
}
