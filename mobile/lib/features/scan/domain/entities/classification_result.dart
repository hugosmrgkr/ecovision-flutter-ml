/// A single-label result displayed by the app.
///
/// In Week 4 this comes ONLY from a mock implementation and must never be
/// presented as a real model prediction.
class ClassificationResult {
  const ClassificationResult({
    required this.label,
    required this.confidence,
    required this.isMock,
  }) : assert(confidence >= 0 && confidence <= 1);

  final String label;
  final double confidence;
  final bool isMock;
}
