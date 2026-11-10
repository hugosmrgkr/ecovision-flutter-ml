import 'dart:convert';

import 'package:ecovision/features/result/presentation/screens/result_screen.dart';
import 'package:ecovision/features/scan/domain/entities/classification_result.dart';
import 'package:ecovision/features/scan/domain/entities/scan_image.dart';
import 'package:ecovision/features/scan/domain/repositories/classification_repository.dart';
import 'package:ecovision/features/scan/domain/repositories/scan_image_repository.dart';
import 'package:ecovision/features/scan/presentation/viewmodels/scan_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Picker implements ScanImageRepository {
  const _Picker(this.image);

  final ScanImage image;

  @override
  Future<ScanImage?> pick(ScanImageSource source) async => image;

  @override
  Future<ScanImage?> recoverLostImage() async => null;
}

class _Classifier implements ClassificationRepository {
  const _Classifier(this.result);

  final ClassificationResult result;

  @override
  Future<ClassificationResult> classify(ScanImage image) async => result;
}

// An actual, tiny valid PNG to keep image decoder errors out of widget tests.
final _photo = ScanImage(
  bytes: base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91Jpz'
    'AAAAFklEQVR4nGP8//8/AwMDEwMDAwMDAwAkBgMB/DXemwAAAABJRU5ErkJggg==',
  ),
  name: 'catatan-kertas.png',
);

Future<ProviderContainer> _preparedContainer(
  ClassificationResult result,
) async {
  final container = ProviderContainer(
    overrides: [
      scanImageRepositoryProvider.overrideWithValue(_Picker(_photo)),
      classificationRepositoryProvider.overrideWithValue(_Classifier(result)),
    ],
  );
  final viewModel = container.read(scanViewModelProvider.notifier);
  await viewModel.pick(ScanImageSource.gallery);
  final success = await viewModel.analyze();
  expect(success, isTrue);
  return container;
}

void main() {
  testWidgets('without scan data the result screen shows empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ResultScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Belum ada hasil analisis'), findsOneWidget);
    expect(find.byKey(const ValueKey('mockDisclaimer')), findsNothing);
  });

  testWidgets('mock result does not attach a fake label to uploaded photo', (
    tester,
  ) async {
    final container = await _preparedContainer(
      const ClassificationResult(
        label: 'plastic',
        confidence: 0.92,
        isMock: true,
      ),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ResultScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Foto ini belum dianalisis AI'), findsOneWidget);
    expect(find.text('catatan-kertas.png'), findsOneWidget);
    expect(find.text('Contoh kategori: Plastik'), findsNothing);

    final demoToggle = find.byKey(const ValueKey('demoExpansion'));

    // Scroll sampai ExpansionTile dibuat dan terlihat.
    await tester.scrollUntilVisible(
      demoToggle,
      250,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.pumpAndSettle();

    // Buka panel contoh hasil klasifikasi.
    await tester.tap(demoToggle);
    await tester.pumpAndSettle();

    expect(find.text('Contoh kategori: Plastik'), findsOneWidget);
    expect(find.text('Confidence contoh (bukan AI)'), findsOneWidget);
  });

  testWidgets(
    'injected real-style result uses its label and low-confidence UI',
    (tester) async {
      // This fake models the future UI contract, not real TFLite inference.
      final container = await _preparedContainer(
        const ClassificationResult(
          label: 'paper',
          confidence: 0.42,
          isMock: false,
        ),
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: ResultScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kertas'), findsOneWidget);
      expect(find.text('Confidence model'), findsOneWidget);
      expect(find.text('42%'), findsOneWidget);
      expect(find.byKey(const ValueKey('mockDisclaimer')), findsNothing);
      expect(find.textContaining('Keyakinan model rendah.'), findsOneWidget);
    },
  );
}
