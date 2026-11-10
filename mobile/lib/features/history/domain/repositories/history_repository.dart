import '../entities/scan_history_entry.dart';

/// Week 4 interface. A SQLite-backed implementation is deferred to Week 6.
abstract interface class HistoryRepository {
  List<ScanHistoryEntry> getDemoEntries();
}
