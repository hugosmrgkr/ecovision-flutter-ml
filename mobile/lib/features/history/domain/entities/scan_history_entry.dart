/// Demo-only history entry for validating the Week 4 UI.
/// It is NOT a persisted user scan and is NOT an ML inference result.
class ScanHistoryEntry {
  const ScanHistoryEntry({
    required this.id,
    required this.label,
    required this.timestamp,
    required this.confidence,
  }) : assert(confidence >= 0 && confidence <= 1);

  final String id;
  final String label;
  final DateTime timestamp;
  final double confidence;
}
