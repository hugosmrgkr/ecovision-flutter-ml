import 'dart:typed_data';

import 'package:ecovision/features/scan/domain/entities/scan_image.dart';
import 'package:ecovision/features/scan/domain/repositories/scan_image_repository.dart';
import 'package:ecovision/features/scan/presentation/viewmodels/scan_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRepository implements ScanImageRepository {
  FakeRepository({this.result, this.failure});

  final ScanImage? result;
  final Object? failure;

  @override
  Future<ScanImage?> pick(ScanImageSource source) async {
    if (failure != null) throw failure!;
    return result;
  }

  @override
  Future<ScanImage?> recoverLostImage() async => null;
}

void main() {
  final demoImage = ScanImage(
    bytes: Uint8List.fromList([1, 2, 3]),
    name: 'bottle.jpg',
    source: ScanImageSource.gallery,
  );

  test(
    'starts idle and stays idle when image selection is cancelled',
    () async {
      final container = ProviderContainer(
        overrides: [
          scanImageRepositoryProvider.overrideWithValue(FakeRepository()),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(scanViewModelProvider).status, ScanStatus.idle);
      await container
          .read(scanViewModelProvider.notifier)
          .pick(ScanImageSource.gallery);
      expect(container.read(scanViewModelProvider).status, ScanStatus.idle);
      expect(container.read(scanViewModelProvider).image, isNull);
    },
  );

  test('stores the selected image in state', () async {
    final container = ProviderContainer(
      overrides: [
        scanImageRepositoryProvider.overrideWithValue(
          FakeRepository(result: demoImage),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(scanViewModelProvider.notifier)
        .pick(ScanImageSource.gallery);
    expect(container.read(scanViewModelProvider).status, ScanStatus.selected);
    expect(container.read(scanViewModelProvider).image?.name, 'bottle.jpg');
  });

  test('shows a recoverable error when picker throws', () async {
    final container = ProviderContainer(
      overrides: [
        scanImageRepositoryProvider.overrideWithValue(
          FakeRepository(failure: Exception('camera unavailable')),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(scanViewModelProvider.notifier)
        .pick(ScanImageSource.camera);
    final state = container.read(scanViewModelProvider);
    expect(state.status, ScanStatus.error);
    expect(state.errorMessage, isNotEmpty);
  });
}
