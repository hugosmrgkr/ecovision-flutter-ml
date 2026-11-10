# Pilahin — Week 4 Day 5: Result Screen UI + honest mock separation

## Goal

Fix misleading Week 4 mock behavior in the UI without pretending the real TensorFlow Lite classifier is connected. The earlier mock always returned `plastic` with `0.92` regardless of image content: a paper photo could appear to be classified as plastic. This patch changes **presentation only** while preserving the repository and ViewModel contracts for Week 5.

## Files

Replace:
- `mobile/lib/features/result/presentation/screens/result_screen.dart`

Add:
- `mobile/lib/features/result/domain/waste_sorting_guide.dart`
- `mobile/test/result/waste_sorting_guide_test.dart`
- `mobile/test/result/result_screen_test.dart`

This patch does not modify any ML model, `pubspec.yaml`, `main.dart`, `go_router`, image picker, or existing test file.

## User-visible changes

- On W4 mock results, the image is **not** labeled as plastic. Instead a prominent `Foto ini belum dianalisis AI` banner explains that no inference happened.
- The user photo appears in its own preview card with `Tidak ada label yang ditentukan untuk foto ini.`
- The **fake** plastic/92% classification is hidden behind a closed `Lihat contoh desain kartu hasil` expansion, and explicitly labeled as data dummy unrelated to the photo.
- Inside the optional demo are a category icon, confidence progress bar, and step-by-step guidance card.
- Guide text for all six ML contract labels exists in a separate, pure-Dart domain mapping. It should be reviewed for local recycling rules before release.
- Result Screen also supports a repository-supplied `isMock=false` state in future Week 5. This does **not** mean TensorFlow Lite is integrated yet.
- Displays a low-confidence note when an injected result has confidence below 70%; **70% is a provisional heuristic, not a calibrated threshold**.

## Apply safely

1. Stop any `flutter run` session (press `q`).
2. At repo root, run `git status --short` and save/commit the working Day 1–4 changes or make a backup; avoid overwriting files if they have been independently edited.
3. Extract the ZIP into `E:\PROJECT\ecovision-flutter-ml` so the existing `mobile/` folder is merged. Do not extract into `mobile/mobile/`.
4. No package installation needed. Keep the currently working Flutter 3.35.5 + Dart 3.9.2 environment.

From Windows PowerShell:

```powershell
cd E:\PROJECT\ecovision-flutter-ml\mobile
dart format lib test
flutter analyze
flutter test
flutter run -d chrome
```

## Manual checks

1. `Beranda` > `Mulai Scan` > `Galeri`, choose a paper/photo of handwriting. Tap `Analisis (Simulasi)`.
2. The first visible result should be **Foto ini belum dianalisis AI** and the uploaded photo, not `Plastik 92%`.
3. Expand `Lihat contoh desain kartu hasil`: ONLY inside that section should `Contoh kategori: Plastik` and `Confidence contoh (bukan AI) 92%` appear. It is a *UI example*, not a prediction.
4. Check guide card and `Scan Lagi`, ensuring the picker selection resets.
5. Try another photo. Mock mode should still avoid assigning a real label.

Expected test suite is **15 tests** if the prior Day 4 build is unchanged (10 prior + 5 new); don't claim success until the user's local run verifies it. Any pre-existing code differences can change the count.

## Next: real ML (Week 5)

The current `classificationRepositoryProvider` is still wired to `MockClassificationRepository` in `scan_view_model.dart`. Week 5 must replace it with a TFLite repository/service, while keeping the `ClassificationResult(label, confidence, isMock)` interface. Before that:

- Model input `[1,224,224,3]`, `float32`, RGB values 0–255; **model itself handles [-1,1] normalization**.
- Match the training pipeline's bilinear resize with antialiasing; do not silently substitute an incompatible image transform. Verify using sample inputs comparing Python and Dart.
- Preserve the exact label order: cardboard, glass, metal, paper, plastic, trash (`ml/models/v1/labels.json`).
- Verify model + labels copied into Flutter assets from the v1 model artifacts; do not rename/reorder labels.
- Test numeric/top-1 parity, native Android inference, latency, and offline operation on a real Android device.
- Do not present TrashNet Keras accuracy as proven Android/TFLite real-photo accuracy.

## Known limitations

The code in this patch was **not executed against the developer's Windows Flutter installation**. Rendering & widget tests require validation there. History is still an empty placeholder, and database persistence remains planned for Week 6.
