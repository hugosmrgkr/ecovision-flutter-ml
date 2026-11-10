import '../entities/scan_image.dart';

abstract class ScanImageRepository {
  /// Null means the user cancelled the system picker.
  Future<ScanImage?> pick(ScanImageSource source);

  /// Best-effort Android activity-restoration handling.
  Future<ScanImage?> recoverLostImage();
}
