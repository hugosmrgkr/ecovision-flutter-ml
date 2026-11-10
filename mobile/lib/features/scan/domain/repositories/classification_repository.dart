import '../entities/classification_result.dart';
import '../entities/scan_image.dart';

/// Week 5 will provide an on-device TFLite implementation of this contract.
abstract class ClassificationRepository {
  Future<ClassificationResult> classify(ScanImage image);
}
