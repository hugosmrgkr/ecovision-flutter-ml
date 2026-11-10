# Pilahin — Week 4 Day 4: Mock Classification Flow

## What this patch does

- Makes the disabled `Analisis (tersedia Day 4)` button functional after an image is selected.
- Adds a `ClassificationRepository` interface and `MockClassificationRepository` implementation.
- Runs a brief simulated loading state and opens the Result page.
- Shows a photo, an **illustrative** class `plastic` and **illustrative** confidence `92%` plus a conspicuous *not a real AI prediction* warning.
- Handles no image, simulated error, retry, and scan-again states.
- Adds 4 unit tests to the existing 6-test suite (target **10 tests**, not guaranteed until run).

**Crucial:** The mock always returns `plastic / 92%` regardless of the photo. It does not call TensorFlow, TFLite, or any model. Don't use it as proof of image recognition. TFLite integration is planned for Week 5.

## Apply the patch safely

1. Exit `flutter run` by pressing `q` in its terminal.
2. Run `git status --short` at repository root. Keep a backup or commit the verified W4 Day 1–3 changes before replacing files. Don't overwrite `mobile/test/widget_test.dart`, which contains your Day 2 scrolling fix. This patch does **not** include that file.
3. Extract ZIP into `E:\PROJECT\ecovision-flutter-ml` so that `mobile/` overlays the existing `mobile/` tree. Do **not** extract into `mobile/mobile/`.
4. No new packages are needed. The existing `flutter_riverpod:3.3.2`, `go_router:17.2.3` and `image_picker:1.2.2` are sufficient.

Run from Windows PowerShell (using E: Flutter PATH):

```powershell
cd E:\PROJECT\ecovision-flutter-ml\mobile
dart format lib test
flutter analyze
flutter test
flutter run -d chrome
```

## Manual acceptance checks

- Open Beranda -> Mulai Scan -> Galeri; select a JPG/PNG.
- The `Analisis (Simulasi)` button is enabled with a selected image.
- Tap it: see a short loading state, then the Result screen.
- Check the sample image remains visible; the demo data is clearly marked as simulation (NOT a real model prediction).
- Tap `Scan Lagi`: selection should reset and Scan page should be empty.
- Open `/result` directly with no selected image: app should show an empty result screen, not crash.
- Verify tapping analysis with no selected image is disabled, and picking another image invalidates the old result.

## Known limitations

- Real object recognition, confidence calibration, preprocessing parity, Android camera verification, offline TFLite inference, and actual-device performance are not done here.
- This patch deliberately does **not** alter the history or persist images.
- This patch hasn't been executed on the developer's Windows/Flutter installation; inspect the results before calling the step complete.

## Expected changed/new files

Changed:
- `mobile/lib/features/scan/presentation/viewmodels/scan_view_model.dart`
- `mobile/lib/features/scan/presentation/screens/scan_screen.dart`
- `mobile/lib/features/result/presentation/screens/result_screen.dart`

Added:
- `mobile/lib/features/scan/domain/entities/classification_result.dart`
- `mobile/lib/features/scan/domain/repositories/classification_repository.dart`
- `mobile/lib/features/scan/data/repositories/mock_classification_repository.dart`
- `mobile/test/scan/mock_classification_test.dart`
