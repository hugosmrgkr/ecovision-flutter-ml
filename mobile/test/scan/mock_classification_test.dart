import 'dart:typed_data';

import 'package:ecovision/features/scan/data/repositories/mock_classification_repository.dart';
import 'package:ecovision/features/scan/domain/entities/classification_result.dart';
import 'package:ecovision/features/scan/domain/entities/scan_image.dart';
import 'package:ecovision/features/scan/domain/repositories/classification_repository.dart';
import 'package:ecovision/features/scan/domain/repositories/scan_image_repository.dart';
import 'package:ecovision/features/scan/presentation/viewmodels/scan_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _ImageRepository implements ScanImageRepository {
  _ImageRepository(this.image);

  final ScanImage image;

  @override
  Future<ScanImage?> pick(ScanImageSource source) async => image;

  @override
  Future<ScanImage?> recoverLostImage() async => null;
}

class _Classifier implements ClassificationRepository {
  _Classifier({this.failure});

  final Object? failure;
  final double confidence = 0.92;
  int callCount = 0;

  @override
  Future<ClassificationResult> classify(ScanImage image) async {
    callCount++;

    if (failure != null) {
      throw failure!;
    }

    return ClassificationResult(
      label: 'plastic',
      confidence: confidence,
      isMock: true,
    );
  }
}

void main() {
  final image = ScanImage(
    bytes: Uint8List.fromList([1, 2, 3]),
    name: 'test.jpg',
    source: ScanImageSource.gallery,
  );

  test('cannot analyze before an image is selected', () async {
    final classifier = _Classifier();

    final container = ProviderContainer(
      overrides: [
        classificationRepositoryProvider.overrideWithValue(classifier),
      ],
    );

    addTearDown(container.dispose);

    final ready = await container
        .read(scanViewModelProvider.notifier)
        .analyze();

    expect(ready, isFalse);
    expect(classifier.callCount, 0);
    expect(container.read(scanViewModelProvider).result, isNull);
  });

  test('analyzes a selected image through the repository interface', () async {
    final classifier = _Classifier();

    final container = ProviderContainer(
      overrides: [
        scanImageRepositoryProvider.overrideWithValue(_ImageRepository(image)),
        classificationRepositoryProvider.overrideWithValue(classifier),
      ],
    );

    addTearDown(container.dispose);

    final vm = container.read(scanViewModelProvider.notifier);

    await vm.pick(ScanImageSource.gallery);

    final ready = await vm.analyze();
    final state = container.read(scanViewModelProvider);

    expect(ready, isTrue);
    expect(state.status, ScanStatus.success);
    expect(state.result?.label, 'plastic');
    expect(state.result?.confidence, 0.92);
    expect(state.result?.isMock, isTrue);
    expect(classifier.callCount, 1);
  });

  test('classifier failure leaves selected image and shows an error', () async {
    final container = ProviderContainer(
      overrides: [
        scanImageRepositoryProvider.overrideWithValue(_ImageRepository(image)),
        classificationRepositoryProvider.overrideWithValue(
          _Classifier(failure: Exception('simulated failure')),
        ),
      ],
    );

    addTearDown(container.dispose);

    final vm = container.read(scanViewModelProvider.notifier);

    await vm.pick(ScanImageSource.gallery);

    final ready = await vm.analyze();
    final state = container.read(scanViewModelProvider);

    expect(ready, isFalse);
    expect(state.status, ScanStatus.error);
    expect(state.image?.name, 'test.jpg');
    expect(state.errorMessage, isNotEmpty);
  });

  test('mock classifier does not actually inspect image contents', () async {
    const mock = MockClassificationRepository();

    final first = await mock.classify(image);

    final other = await mock.classify(
      ScanImage(bytes: Uint8List.fromList([9, 8, 7]), name: 'other.jpg'),
    );

    expect(first.isMock, isTrue);
    expect(first.label, other.label);
    expect(first.confidence, other.confidence);
  });
}
