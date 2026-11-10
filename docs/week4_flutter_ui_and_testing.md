# Pilahin — Week 4 Flutter UI & Engineering Report

> Product/UI name: **Pilahin**. Repository name remains `ecovision-flutter-ml`.
>
> This report distinguishes completed local verification from code delivered for testing. It is not an Android release report.

## 1. Scope

Week 4 builds the Android-first Flutter presentation foundation:
- Material 3 brand theme and responsive home screen.
- `go_router` routes for Home, Scan, Result, History, and Guide.
- Riverpod state management and repository interfaces.
- Camera/gallery selection via `image_picker`, image validation and preview.
- Mock analysis flow, loading/error state, and an **explicit** no-AI result notice.
- UI examples for a future classification card, sorting guide, and history.
- Widget/unit tests, Android QA checklist, and Flutter CI checks.

**Out of scope:** real on-device ML prediction (Week 5), persistence of scan records (Week 6), multi-object detection, cloud backend, and production release APK (Week 8).

## 2. Architecture at Week 4

```text
mobile/lib/
  app/                 app/router, theme
  core/widgets/        reusable icons/components
  features/
    home/presentation/
    scan/domain/        entities and repository interfaces
    scan/data/          image_picker adapter and mock classifier
    scan/presentation/  scan screen and Riverpod viewmodel
    result/domain/      shared material sorting guide
    result/presentation/
    history/domain/     demo record entity and repository interface
    history/data/       deterministic, in-memory DEMO repository
    history/presentation/
    guide/presentation/
```

The Week 4 `classificationRepositoryProvider` binds `MockClassificationRepository`, so the app does not yet infer material from pixels. On the result screen, simulated classification does **not** attach a fake label or score to the uploaded image. The expandable example card is explicitly separate from the photo.

**History is also demo-only.** By default it shows an empty state. Users opt into a visibly labeled example list containing six fixed synthetic records with illustration icons, not user photographs. Filtering and viewing example guides never write to storage. Real history storage is planned for Week 6.

## 3. Actual verification evidence supplied by developer

The developer reported, after fixing a widget-test scroll issue on Day 5:

- `flutter analyze`: **No issues found**.
- `flutter test`: **15 tests passed**.
- Chrome: Home navigation, gallery selection, image preview, and mock-result presentation were visually checked through screenshots.
- Flutter SDK: Windows **Flutter 3.35.5**, **Dart 3.9.2** at `E:\dev\flutter`.
- Android toolchain: `flutter doctor -v` reported Android SDK **36.1.0** and accepted licenses, but **no Android emulator/device was connected at that time**.

These observations predate the final Day 6/7 files delivered with this report. **No new test pass count is asserted** until the developer runs the updated suite on their machine or CI.

## 4. Test plan for final Week 4 patch

Automated:
1. `flutter pub get`
2. `dart format lib test` (commit formatted files)
3. `flutter analyze`
4. `flutter test`
5. `git diff --check`

The final patch adds targeted tests for demo history repository/filter, default empty history, opt-in demo, category filter, and guide expansion. Ensure previous 15 tests continue to pass. Test totals must be read from actual command output; no assumed totals.

Manual Chrome:
- Home -> Scan, choose image, preview, remove, cancel preserving previous image.
- Analyze (Simulasi) -> Result: uploaded photo has no AI-assigned label; expandable demo result is separately and visibly labeled.
- History -> initially empty; opt in to demo; filter and search example labels; view example detail; close demo to return to empty state.
- Guide -> expand each of six categories; check text wraps on small viewport.

Android: see [`docs/week4_android_test_matrix.md`](week4_android_test_matrix.md).

## 5. Privacy and limitations

No login, analytics, network inference, or cloud storage are implemented in Week 4. `image_picker` provides local images; the app holds image bytes temporarily in memory. Captured-image temporary files may be placed in the app's cache by the platform/plugin. Do not claim permanent privacy guarantees without inspecting device behavior. Avoid committing real user images, dataset files, and temporary captures to Git.

No accuracy or latency claims for the Flutter app are appropriate at this stage. Keras offline test evaluation from Week 3 is not an Android inference benchmark.

## 6. Definition of Done (conditional)

W4 can be marked **complete** only when:
- [ ] Flutter analyzer is clean after final patch
- [ ] all existing and added tests pass
- [ ] final Chrome manual checks pass
- [ ] emulator/Android manual tests recorded with evidence (or explicitly open as a blocker)
- [ ] no unreviewed changes, datasets, user images, or secrets are committed
- [ ] Git commit and remote push are confirmed

A complete app/model release is *not* part of Week 4.
