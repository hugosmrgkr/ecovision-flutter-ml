import 'dart:typed_data';

enum ScanImageSource { camera, gallery }

/// A temporary in-memory image selected for a single-object scan.
/// It is not persisted to local storage in Week 4.
class ScanImage {
  const ScanImage({required this.bytes, required this.name, this.source});

  final Uint8List bytes;
  final String name;
  final ScanImageSource? source;
}
