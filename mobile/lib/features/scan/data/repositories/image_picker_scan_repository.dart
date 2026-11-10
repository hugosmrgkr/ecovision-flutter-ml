import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/scan_image.dart';
import '../../domain/repositories/scan_image_repository.dart';

class InvalidScanImageException implements Exception {
  const InvalidScanImageException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Platform adapter. Keeps `image_picker` out of the view model and widgets.
class ImagePickerScanRepository implements ScanImageRepository {
  ImagePickerScanRepository({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  static const maxImageBytes = 20 * 1024 * 1024;
  final ImagePicker _picker;

  @override
  Future<ScanImage?> pick(ScanImageSource source) async {
    final file = await _picker.pickImage(
      source: source == ScanImageSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
    );
    if (file == null) return null;
    return _validateAndRead(file, source: source);
  }

  @override
  Future<ScanImage?> recoverLostImage() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return null;
    }
    final response = await _picker.retrieveLostData();
    if (response.exception != null) throw response.exception!;
    final files = response.files;
    if (files == null || files.isEmpty) return null;
    // Android may restore a picker result without knowing its original source.
    return _validateAndRead(files.first);
  }

  Future<ScanImage> _validateAndRead(
    XFile file, {
    ScanImageSource? source,
  }) async {
    final size = await file.length();
    if (size == 0 || size > maxImageBytes) {
      throw const InvalidScanImageException(
        'Gambar kosong atau lebih besar dari 20 MB. Pilih foto lain.',
      );
    }

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty || bytes.lengthInBytes > maxImageBytes) {
      throw const InvalidScanImageException(
        'Gambar kosong atau lebih besar dari 20 MB. Pilih foto lain.',
      );
    }

    // Validate actual decodability instead of relying on the extension/name.
    ui.Codec? codec;
    try {
      codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      frame.image.dispose();
    } catch (_) {
      throw const InvalidScanImageException(
        'File tidak dapat dibaca sebagai gambar. Coba JPG atau PNG.',
      );
    } finally {
      codec?.dispose();
    }
    return ScanImage(bytes: bytes, name: file.name, source: source);
  }
}
