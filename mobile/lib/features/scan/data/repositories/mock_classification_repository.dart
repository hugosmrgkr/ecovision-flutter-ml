import '../../domain/entities/classification_result.dart';
import '../../domain/entities/scan_image.dart';
import '../../domain/repositories/classification_repository.dart';

/// Fake inference for developing the UI. The image is NOT analyzed.
/// Always returns the same illustrative result, regardless of its contents.
class MockClassificationRepository implements ClassificationRepository {
  const MockClassificationRepository();

  @override
  Future<ClassificationResult> classify(ScanImage image) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return const ClassificationResult(
      label: 'plastic',
      confidence: 0.92,
      isMock: true,
    );
  }
}
