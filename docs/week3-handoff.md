# EcoVision — Week 3 Technical Handoff for Week 4

**Project:** `ecovision-flutter-ml`

**Checkpoint:** frozen MobileNetV2 epoch 8, experiment `mobilenetv2_frozen_20261103_155149`

**Stage:** Week 3 ML evaluation and TFLite conversion; documentation drafted

**Status policy:** Only the results shown in executed local notebooks are described as verified. No Git commit/push or Android integration is claimed here.

## Verified from developer outputs

- Week 2 git state at the beginning of Week 3: commit `87059f8`, `main` synchronized with `origin/main`, clean working tree at that time.
- Restored frozen checkpoint exists and matches SHA-256 `0d560451fbd667f42c852752436a0ffc77f8068b8bd3b326ded4bd16bc3e6023`.
- `labels.json` contains `cardboard`, `glass`, `metal`, `paper`, `plastic`, `trash` in that order and matches training notebook constants.
- Test split: 380 files, SHA-256 all matched, checked no cross-split overlap in path, SHA-256, or `group_id`.
- TensorFlow 2.21.0 in the WSL Jupyter kernel discovered NVIDIA RTX 3050 GPU.
- Frozen Keras final TrashNet test: **324/380 correct**, **85.2632% accuracy**, **82.5654% macro-F1**.
- TFLite float32 export succeeded; **8.513 MiB**; file SHA-256 `203947d3ce6b9fcacee91d5827a1ba0cefc2b3cf0207e9ffe1dbd7825f6d1aed`.
- Twelve validation images: Keras CPU vs TFLite CPU top-1 **12/12**, `allclose` **True** (`atol=rtol=1e-3`), max absolute difference ≈ `3.844e-6`.
- First mixed-backend comparison (Keras GPU vs TFLite CPU) did **not** pass the same numeric tolerance; this should stay documented.
- Model metadata and detailed parity JSON files were reported successfully saved by Cell D.

## Files that now exist locally (reported)

- `ml/notebooks/03_model_evaluation.ipynb`
- `ml/notebooks/04_tflite_export_and_parity.ipynb` (edited for CPU parity)
- `ml/models/v1/labels.json`
- `ml/models/v1/ecovision_mobilenetv2_float32_v1.tflite`
- `ml/models/v1/model_metadata.json`
- `ml/reports/generated/week3/{frozen_final_test_metrics.json,frozen_final_test_per_class.csv,frozen_final_test_predictions.csv,frozen_final_test_confusion_matrix.png,tflite_parity_validation.json}`

The last path group belongs to **local-only, Git-ignored** generated results. Files generated in the present documentation package should be placed at their corresponding repo-relative paths.

## Final model contract

- Single dominant object, six broad TrashNet categories.
- Image input: RGB `[1,224,224,3]`, float32, raw pixel values 0–255.
- Preprocess: decode RGB, bilinear resize with `antialias=True` in the evaluated Python pipeline; no external normalization.
- Normalization inside the model: `x / 127.5 - 1`.
- Output: float32 `[1,6]` softmax probabilities, indexed by `labels.json`.
- No quantization; v1 TFLite artifact SHA-256 pinned above.

## Open verification items before declaring Week 3 fully archived

1. Review `model_metadata.json` and `tflite_parity_validation.json` contents and ensure CPU backend/difference notes are correctly recorded.
2. Ensure notebooks were saved with the actual local corrections (`antialias=True` in final test, explicit CPU execution in parity).
3. Keep generated test predictions and raw dataset excluded from Git; review `git status` and repository ignore policy.
4. Optionally add an English Week 3 section to the root README using `docs/week3-readme-snippet.md`.
5. Review the four documentation files for project accuracy and **then** perform Git staging/commit/push (not performed here).

## Week 4 kickoff: engineering plan

1. Confirm Flutter SDK and dependency versions from the local environment before changing `pubspec.yaml`.
2. Create/confirm feature-first Flutter structure using Presentation / Domain / Data with MVVM + Riverpod + Repository Pattern and go_router.
3. Build screens and states for Home, Scan, Preview, Result; support camera/gallery selection but keep inference behind a mockable repository interface initially.
4. Add widget tests for screen states and navigation, and unit tests for any non-UI business logic.
5. Plan Week 5 model bundling with checksum checks, image preprocessing fixture parity, and Android offline runtime tests.

**Do not claim:** TFLite Android accuracy, on-device latency, smartphone-photo generalization, full Flutter integration, or Week 3 push until tested/confirmed.
