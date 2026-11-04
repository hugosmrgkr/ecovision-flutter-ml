# EcoVision — Week 3 Final Model Evaluation Report

**Project:** EcoVision — AI-Powered Waste Classification Mobile App

**Repository:** `ecovision-flutter-ml`

**Stage:** Week 3 — frozen baseline final evaluation

**Model selected before testing:** `mobilenetv2_frozen_20261103_155149`, checkpoint from epoch 8

**Evidence:** developer-executed local VS Code / WSL notebook results, reported November 2026

**Status:** Final TrashNet v1 test evaluation observed; Android/real-world evaluation pending

## 1. Executive summary

The preselected **frozen MobileNetV2** checkpoint correctly classified **324 of 380** TrashNet v1 test images (**85.2632% accuracy**) with **82.5654% macro-F1**. The model was selected using validation metrics *before* this independent test evaluation; the test results were not used to select another checkpoint, retune the model, or change decision thresholds.

| Metric | Independent test result |
|---|---:|
| Test images | 380 |
| Correct predictions | 324 |
| Accuracy | **85.2632%** |
| Macro precision | **82.4528%** |
| Macro recall | **83.0341%** |
| Macro-F1 | **82.5654%** |

**Scope:** These metrics are for the saved Keras frozen checkpoint evaluated on the TrashNet v1 test split, **not** measured Android/TFLite accuracy. The separately exported float32 TFLite model passed a 12-image *validation* CPU-to-CPU parity check (see Section 6), which is not a substitute for full deployment testing.

## 2. Dataset and evaluation protocol

- **Source:** [TrashNet — Gary Thung and Mindy Yang](https://github.com/garythung/trashnet).
- **Original local inventory:** 2,527 readable images; zero unreadable.
- **Clean manifest:** 2,524 images after excluding three exact-duplicate copies with conflicting source labels. Decisions are logged in `ml/data/cleaning_decisions.csv`.
- **Similarity review:** 42 pHash-distance <= 6 candidate pairs manually reviewed; 32 considered grouped, 3 uncertain grouped conservatively, 7 considered different. Group-aware splitting produced 2,489 groups.
- **Final fixed split v1:** 1,766 train, 378 validation, 380 test. Manifests: `ml/data/splits/v1/{train,val,test}.csv`.
- **Pre-test checks observed:** test distribution, all 380 test image SHA-256 hashes, and lack of cross-split overlap in paths, SHA-256 hashes, and `group_id` identifiers.
- **Class order:** `cardboard`, `glass`, `metal`, `paper`, `plastic`, `trash`, checked against the Week 2 notebook and `ml/models/v1/labels.json`.
- **Checkpoint selection policy:** the frozen model was chosen on validation macro-F1 and minority-class (`trash`) recall, not based on test predictions.
- **Input pipeline:** RGB image decode; bilinear resize to 224 × 224 with `antialias=True`; float32 values 0–255. Normalization `x / 127.5 - 1` is implemented inside the model.

These checks reduce the risk of train/test contamination but do **not** prove the absence of all correlated or near-duplicate photographs beyond the documented screening method.

## 3. Validation-to-test comparison

| Metric | Frozen validation (378) | Final test (380) |
|---|---:|---:|
| Accuracy | 85.98% | **85.26%** |
| Macro precision | 83.07% | **82.45%** |
| Macro recall | 82.48% | **83.03%** |
| Macro-F1 | 82.73% | **82.57%** |
| `trash` recall | 57.14% (12/21) | **66.67% (14/21)** |

The overall validation/test scores are similar, but performance on a single minority class is uncertain because `trash` has only 21 images in each validation/test partition. Do not interpret the change in `trash` recall as a proven improvement.

## 4. Per-class performance on the 380-image test set

| Class | Precision | Recall | F1-score | Support | Correct |
|---|---:|---:|---:|---:|---:|
| `cardboard` | 96.23% | 85.00% | 90.27% | 60 | 51 |
| `glass` | 85.71% | 80.00% | 82.76% | 75 | 60 |
| `metal` | 83.33% | 90.16% | 86.61% | 61 | 55 |
| `paper` | 86.96% | 89.89% | 88.40% | 89 | 80 |
| `plastic` | 86.49% | 86.49% | 86.49% | 74 | 64 |
| `trash` | 56.00% | 66.67% | 60.87% | 21 | 14 |

The weakest class by F1 is `trash`, followed by `glass`. A high confidence score does **not** necessarily imply a calibrated probability of correctness; confidence calibration has not been demonstrated.

## 5. Confusion matrix and error analysis

**Rows = true class; columns = predicted class.** Class order matches `labels.json`.

| True \\ Predicted | cardboard | glass | metal | paper | plastic | trash |
|---|---:|---:|---:|---:|---:|---:|
| cardboard | **51** | 0 | 0 | 7 | 0 | 2 |
| glass | 0 | **60** | 8 | 0 | 6 | 1 |
| metal | 0 | 1 | **55** | 1 | 1 | 3 |
| paper | 1 | 4 | 0 | **80** | 0 | 4 |
| plastic | 0 | 5 | 2 | 2 | **64** | 1 |
| trash | 1 | 0 | 1 | 2 | 3 | **14** |

Observed error patterns:

- **Glass → metal:** 8/75 glass test images; **glass → plastic:** 6/75.
- **Cardboard → paper:** 7/60 cardboard images.
- **Plastic → glass:** 5/74 plastic images.
- **Trash:** 7/21 misses spread across cardboard (1), metal (1), paper (2), and plastic (3). In addition, the model predicts `trash` for several non-trash images, which contributes to `trash` precision of 56.00%.

These are classification observations, not confirmed physical-material explanations. Investigating the underlying images can be valuable for future research, but must not be used to tune the frozen v1 model against its sealed test set.

## 6. TFLite export and parity evidence

| Artifact / check | Observed value |
|---|---|
| Export source | Frozen epoch-8 `.keras` checkpoint |
| Source checkpoint SHA-256 | `0d560451fbd667f42c852752436a0ffc77f8068b8bd3b326ded4bd16bc3e6023` |
| TFLite filename | `ml/models/v1/ecovision_mobilenetv2_float32_v1.tflite` |
| Conversion | Float32, without quantization |
| Input | `[1, 224, 224, 3]`, float32, RGB, pixel values 0–255 |
| Output | `[1, 6]`, float32 probabilities |
| Model size | **8.513 MiB** (reported rounded) |
| TFLite SHA-256 | `203947d3ce6b9fcacee91d5827a1ba0cefc2b3cf0207e9ffe1dbd7825f6d1aed` |

**Parity dataset:** 12 deterministic validation images (first two rows per class in `val.csv`), with SHA-256 verification. Exactly the same decoded/resized image arrays were supplied to both runtimes. Tolerance: `atol = 1e-3`, `rtol = 1e-3`.

| Comparison | Top-1 agreement | Maximum absolute probability difference | Mean absolute difference | Values outside tolerance | Numeric allclose |
|---|---:|---:|---:|---:|---|
| Keras GPU vs TFLite CPU | 12/12 | 0.01034905 | 0.00088566 | 9/72 | **False** |
| **Keras CPU vs TFLite CPU (XNNPACK)** | **12/12** | **0.000003844** | **0.000000255** | **0/72** | **True** |
| Keras GPU vs Keras CPU | 12/12 | 0.01035036 | 0.00088583 | 9/72 | **False** |

Interpretation: the CPU-to-CPU comparison passes the predefined parity tolerance. The close agreement of Keras CPU and TFLite CPU, together with the similar GPU-versus-CPU divergence in Keras itself, strongly suggests a backend-dependent numerical difference, **not** a demonstrated TFLite conversion defect. This does not establish universal equality for all images, backend configurations, or Android implementations. Preserve the GPU/CPU discrepancy in the technical record.

**Local parity evidence:** `ml/reports/generated/week3/tflite_parity_validation.json` (locally generated, Git-ignored). Export metadata: `ml/models/v1/model_metadata.json` (created locally; content should be reviewed before Git staging).

## 7. Runtime timing: what was and was not measured

The final test notebook reported **20.85 seconds total wall-clock** for processing 380 test images, including data pipeline and initialization/warm-up effects on the developer workstation (WSL / NVIDIA RTX 3050). This measurement is **not** a per-image Android inference latency measurement and should not be compared with mobile-device latency requirements.

## 8. Threats to validity and known limitations

1. TrashNet images often have controlled backgrounds; real-world smartphone photos may differ substantially.
2. Classes are imbalanced (notably `trash`); test `trash` support is only 21 images.
3. Some visually reviewed labels and uncertain similarity groups were classified from pixels, without independent physical-object confirmation.
4. The pHash similarity review is heuristic; unseen correlated images may remain.
5. The six labels are broad material categories; mixed, contaminated, or multi-object scenes are outside the model's validated scope.
6. The v1 model has not been evaluated on a separately collected smartphone-photo set.
7. Android-device inference, Flutter preprocessing parity, offline end-to-end execution, and latency remain **pending**.
8. Confidence calibration and a validated low-confidence threshold have **not** been established.
9. Only 12 validation samples were used for numerical parity; this is a targeted smoke test, not exhaustive verification.
10. The fixed v1 test split has been used for its final frozen-Keras evaluation; do not treat it as a tuning dataset.

## 9. Reproducibility and artifacts

**Tracked candidates for commit (after review):**

- `ml/notebooks/03_model_evaluation.ipynb` — ensure the locally saved Cell E uses `antialias=True`.
- `ml/notebooks/04_tflite_export_and_parity.ipynb` — ensure the locally saved Cell C compares Keras on CPU against TFLite CPU and does not falsely claim GPU-to-CPU numeric closeness.
- `ml/models/v1/labels.json`
- `ml/models/v1/model_metadata.json` — inspect actual contents and parity backend declaration.
- `ml/models/v1/ecovision_mobilenetv2_float32_v1.tflite` — optionally track as a versioned binary if repository policy permits; do not silently replace an existing version.
- `ml/reports/week3_model_evaluation.md` (this report), `docs/model-card-v1.md`, and `docs/week3-reproducibility.md`.

**Intentionally kept local / Git-ignored:**

- `ml/data/raw/` — original image data and archives.
- `ml/reports/generated/week2/` — `.keras` checkpoints and local training outputs.
- `ml/reports/generated/week3/` — test predictions, metrics JSON, per-class CSV, confusion matrix PNG, parity JSON.
- Local virtual environments, personal files, and any secrets.

## 10. Next verification milestones

- Validate model and TensorFlow Lite preprocessing against Flutter/Dart on the **same image bytes**.
- Measure per-image inference time and memory usage on a real Android device.
- Test offline camera/gallery scanning and error/permission states.
- Collect an independent smartphone-photo evaluation set and report performance separately from TrashNet test metrics.
- Before release, document the exact model/labels/metadata binaries bundled in the APK with checksums.

**Conclusion:** The frozen baseline provides a documented six-class TrashNet evaluation and a float32 TFLite export that passed a limited but meaningful CPU parity test. It is suitable as a **candidate for integration**, not yet as a verified end-to-end Android product.
