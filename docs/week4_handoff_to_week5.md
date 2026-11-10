# Week 4 -> Week 5 Handoff — Pilahin / EcoVision

## Product / repository naming

- Display/UI brand: **Pilahin**.
- Repository and Dart package name: `ecovision-flutter-ml` / `ecovision` (do not arbitrarily rename import paths).
- Android launcher name should be checked in `mobile/android/app/src/main/AndroidManifest.xml` and changed to `Pilahin` if still `ecovision`; preserve Android `applicationId`/namespace for now.

## W4 status at handoff

Previous developer evidence: 15 passing Flutter tests and clean analyzer at the end of Day 5, plus Chrome screenshot of honest mock result UI. This final package adds History showcase, Guide page, tests, CI config, and documentation. Final verification and Android screenshots are still pending until the developer runs them.

## Architecture contract to preserve

- Keep feature-first UI, domain entities, repository interfaces, and data adapters separate.
- `scanViewModelProvider` owns `ScanState` with image, status, result, error.
- `classificationRepositoryProvider` currently provides mock classification. Week 5 should replace it behind the same `ClassificationRepository` interface, **not** add TFLite logic to widgets.
- `ResultScreen` already distinguishes `ClassificationResult.isMock`. Remove the demo-flow path from the normal scan route only after real TFLite inference is correctly integrated and tested.
- History demo repository is in-memory and opt-in only. It must never be written as actual scan history. Week 6 introduces SQLite and separate persisted records.

## Week 3 model contract for integration

- Model artifact: `ml/models/v1/ecovision_mobilenetv2_float32_v1.tflite`.
- Labels order from `ml/models/v1/labels.json`: `cardboard`, `glass`, `metal`, `paper`, `plastic`, `trash`.
- Input: `[1, 224, 224, 3]`, float32, RGB pixels in 0..255.
- The model itself rescales 0..255 to -1..1. **Do not double-normalize**.
- Output: six class probabilities, verify order against `labels.json`.
- Week 3 Keras and TFLite CPU numerical parity was verified on 12 **validation** images, not Android.
- For parity with training/evaluation, match bilinear resize and anti-alias policy (TensorFlow `tf.image.resize(..., antialias=True)`) or quantify any platform differences.
- Preserve versioned model file and metadata. Handle invalid images and low-confidence predictions before displaying guidance.

## First Week 5 tasks

1. Check final Git status, analyzer/tests, Android QA, and version compatibility of chosen TFLite Flutter runtime plugin with Flutter 3.35.5/Dart 3.9.2.
2. Verify `.tflite` asset and `labels.json` bytes/hashes after packaging in Flutter.
3. Implement an isolated TFLite service in `scan/data`, with model-load and disposal lifecycle and controlled input/output tensors.
4. Create preprocessing tests and parity cases with the same test images used by Python.
5. Run Android on-device inference, then benchmark latency/memory and test photos of real-world objects.
6. Only after real inference passes should the UI show per-photo class/confidence. Do not copy Week 3 Keras test accuracy into the Flutter demo as an app benchmark.
