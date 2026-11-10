import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/image_picker_scan_repository.dart';
import '../../data/repositories/mock_classification_repository.dart';
import '../../domain/entities/classification_result.dart';
import '../../domain/entities/scan_image.dart';
import '../../domain/repositories/classification_repository.dart';
import '../../domain/repositories/scan_image_repository.dart';

final scanImageRepositoryProvider = Provider<ScanImageRepository>(
  (ref) => ImagePickerScanRepository(),
);

final classificationRepositoryProvider = Provider<ClassificationRepository>(
  (ref) => const MockClassificationRepository(),
);

final scanViewModelProvider = NotifierProvider<ScanViewModel, ScanState>(
  ScanViewModel.new,
);

enum ScanStatus { idle, picking, selected, analyzing, success, error }

class ScanState {
  const ScanState({
    this.status = ScanStatus.idle,
    this.image,
    this.result,
    this.errorMessage,
  });

  final ScanStatus status;
  final ScanImage? image;
  final ClassificationResult? result;
  final String? errorMessage;
}

class ScanViewModel extends Notifier<ScanState> {
  bool _recoveryChecked = false;

  @override
  ScanState build() => const ScanState();

  Future<void> pick(ScanImageSource source) async {
    if (state.status == ScanStatus.picking ||
        state.status == ScanStatus.analyzing) {
      return;
    }
    final previous = state;
    state = ScanState(
      status: ScanStatus.picking,
      image: previous.image,
      result: previous.result,
    );
    try {
      final selected = await ref.read(scanImageRepositoryProvider).pick(source);
      if (!ref.mounted) return;
      if (selected == null) {
        // Cancelling the picker preserves any previously selected image/result.
        state = ScanState(
          status: previous.image == null
              ? ScanStatus.idle
              : previous.result == null
              ? ScanStatus.selected
              : ScanStatus.success,
          image: previous.image,
          result: previous.result,
        );
        return;
      }
      // A different image invalidates the previous mock result.
      state = ScanState(status: ScanStatus.selected, image: selected);
    } catch (error) {
      if (!ref.mounted) return;
      state = ScanState(
        status: ScanStatus.error,
        image: previous.image,
        result: previous.result,
        errorMessage: _messageFor(error),
      );
    }
  }

  /// Returns true only when a (currently mocked) classification is ready.
  Future<bool> analyze() async {
    final image = state.image;
    if (image == null ||
        state.status == ScanStatus.picking ||
        state.status == ScanStatus.analyzing) {
      return false;
    }

    state = ScanState(status: ScanStatus.analyzing, image: image);
    try {
      final result = await ref
          .read(classificationRepositoryProvider)
          .classify(image);
      if (!ref.mounted) return false;
      state = ScanState(
        status: ScanStatus.success,
        image: image,
        result: result,
      );
      return true;
    } catch (_) {
      if (!ref.mounted) return false;
      state = ScanState(
        status: ScanStatus.error,
        image: image,
        errorMessage: 'Simulasi analisis gagal. Coba lagi.',
      );
      return false;
    }
  }

  Future<void> recoverLostImage() async {
    if (_recoveryChecked) return;
    _recoveryChecked = true;
    try {
      final recovered = await ref
          .read(scanImageRepositoryProvider)
          .recoverLostImage();
      if (!ref.mounted || recovered == null || state.image != null) return;
      state = ScanState(status: ScanStatus.selected, image: recovered);
    } on MissingPluginException {
      // Widget tests may run without a native plugin implementation.
    } catch (error) {
      if (!ref.mounted) return;
      state = ScanState(
        status: ScanStatus.error,
        image: state.image,
        result: state.result,
        errorMessage: _messageFor(error),
      );
    }
  }

  void clear() => state = const ScanState();

  String _messageFor(Object error) {
    if (error is InvalidScanImageException) return error.message;
    if (error is PlatformException) {
      if (error.code.contains('access_denied') ||
          error.code.contains('permission')) {
        return 'Akses ditolak. Periksa izin kamera atau foto di pengaturan perangkat.';
      }
      return 'Tidak berhasil membuka kamera/galeri. Coba lagi.';
    }
    return 'Gagal memuat gambar. Coba foto atau file lain.';
  }
}
