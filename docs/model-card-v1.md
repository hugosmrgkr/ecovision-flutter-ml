# EcoVision Model Card — MobileNetV2 Float32 v1

**Model name:** EcoVision Waste Material Classifier

**Version:** `v1.0.0` (model artifact contract)

**Status:** Exported and locally verified for CPU parity; **Android deployment pending**

**Architecture:** MobileNetV2 (ImageNet-pretrained frozen backbone) + global average pooling + dropout (0.2) + six-class softmax head

**Framework:** TensorFlow/Keras 2.21.0; exported to TensorFlow Lite float32

**Training environment:** Python 3.12.3, WSL2 Ubuntu, NVIDIA RTX 3050 Laptop GPU (4 GB VRAM)

**Maintainer:** EcoVision solo project

## Intended use

EcoVision is an Android-first, offline-first learning and portfolio application intended to classify **one dominant waste object** into one of six TrashNet-style material labels. Its prediction can be used to present basic educational sorting guidance **with appropriate uncertainty warnings**.

This model is **not** a certified recycling identification system, a municipal waste-policy engine, a hazardous-waste detector, or a substitute for local disposal guidelines. It does not perform multi-object detection.

## Model inputs and outputs

| Contract field | Value |
|---|---|
| Input tensor | `[1, 224, 224, 3]` (runtime batch usually 1; model supports dynamic batch dimension) |
| Input dtype | `float32` |
| Color order | RGB |
| Raw input range | Pixel values **0–255** |
| External image processing | Decode RGB; bilinear resize to 224 × 224 with `antialias=True`; cast to float32 |
| Inside the model | `Rescaling(scale=1/127.5, offset=-1)` → values approximately [-1, 1] |
| Output tensor | `[1, 6]` |
| Output dtype | `float32` |
| Output semantics | Softmax probabilities; **not established as calibrated probabilities** |

**Index-to-label order (must not be reordered):**

```json
[
  "cardboard",
  "glass",
  "metal",
  "paper",
  "plastic",
  "trash"
]
```

Canonical label file: `ml/models/v1/labels.json`.

> Integration warning: Applying a second external MobileNetV2 `preprocess_input` or rescaling input to [0,1] would violate the contract. The model already performs internal rescaling.

## Training and version provenance

- Dataset: [TrashNet](https://github.com/garythung/trashnet) (Gary Thung and Mindy Yang).
- Clean dataset: 2,524 images after 3 documented duplicate-copy exclusions.
- Split v1: 1,766 train, 378 validation, 380 test; group-aware and class-stratified.
- Frozen backbone: MobileNetV2 ImageNet weights; only the six-class classification head trained for the frozen experiment.
- Frozen experiment ID: `mobilenetv2_frozen_20261103_155149`; chosen checkpoint **epoch 8**.
- Frozen head experiment: Adam with learning rate `1e-3`, maximum 12 epochs, early stopping and best-checkpoint saving by validation loss, batch size 8, train-only data augmentation.
- Fine-tuning experiment (validation comparison only): `mobilenetv2_finetune_20261103_161943`; not selected as this model version because its validation macro-F1 and `trash` recall were slightly lower than the frozen candidate.
- Selection occurred **before** independent test evaluation.

### File and checksum provenance

| Item | Value |
|---|---|
| Source checkpoint | `ml/reports/generated/week2/mobilenetv2_frozen_20261103_155149/best_model.keras` |
| Keras SHA-256 | `0d560451fbd667f42c852752436a0ffc77f8068b8bd3b326ded4bd16bc3e6023` |
| TFLite model | `ml/models/v1/ecovision_mobilenetv2_float32_v1.tflite` |
| TFLite SHA-256 | `203947d3ce6b9fcacee91d5827a1ba0cefc2b3cf0207e9ffe1dbd7825f6d1aed` |
| TFLite size | 8.513 MiB (rounded) |
| Conversion | Float32 baseline; **no quantization** |
| Metadata | `ml/models/v1/model_metadata.json` |

The `.keras` checkpoint and original dataset are maintained locally outside the public Git history per project policy. Reproduction requires obtaining the source data separately, applying the tracked manifests, and having the saved checkpoint or retraining it.

## Evaluation

Independent TrashNet v1 test set, **380 images**, performed with the frozen Keras checkpoint:

| Metric | Result |
|---|---:|
| Accuracy | **85.2632% (324/380)** |
| Macro precision | 82.4528% |
| Macro recall | 83.0341% |
| Macro-F1 | **82.5654%** |
| `trash` precision | 56.00% |
| `trash` recall | 66.67% (14/21) |
| `trash` F1 | 60.87% |

See [`ml/reports/week3_model_evaluation.md`](../ml/reports/week3_model_evaluation.md) for the full per-class table and confusion matrix.

## TensorFlow Lite validation

The converted model was compared against the source Keras model using the exact same RGB/resize float32 inputs on **12 validation images** (two per class).

- **Keras CPU vs TFLite CPU/XNNPACK:** Top-1 12/12; max absolute probability difference ≈ `3.844e-6`; mean absolute difference ≈ `2.554e-7`; `np.allclose(..., atol=1e-3, rtol=1e-3)` = **True**.
- **Keras GPU vs TFLite CPU:** Top-1 12/12, but maximum probability difference ≈ `0.010349`; **did not** meet the same numeric tolerance.
- **Keras GPU vs Keras CPU:** similar maximum difference ≈ `0.010350`, supporting a backend-dependent numerical explanation.

These findings demonstrate **targeted same-input CPU parity**, not end-to-end Flutter parity, full TFLite test-set accuracy, or universally equivalent predictions on every input.

## Known limitations and risks

1. **Domain shift:** TrashNet's photo conditions differ from varied real smartphone capture environments.
2. **Minority class reliability:** `trash` comprises only 21 test images and has lower precision/F1 than the other classes.
3. **Semantic uncertainty:** `trash` is heterogeneous; material boundaries and recycled-versus-contaminated scenarios may be ambiguous.
4. **No object detection:** The model assumes a single prominent item; cluttered scenes or multiple objects may be misclassified.
5. **No confidence calibration:** Softmax scores should not be interpreted as verified real-world correctness probabilities. A low-confidence display policy must be validated using appropriate development data, not tuned on the final test set.
6. **No Android evidence yet:** Mobile preprocessing parity, runtime compatibility, device latency, memory consumption, and offline integration are pending.
7. **Numerical backend differences:** GPU-vs-CPU output differences can be materially larger than CPU-to-CPU conversion differences on some images.
8. **Dataset review limitations:** Image-based manual label and near-duplicate review does not guarantee perfect labels or complete leakage elimination.

## Responsible presentation

- Display the predicted category as a **suggestion**, not a guarantee.
- Provide simple disposal guidance that notes local regulations may differ.
- Handle invalid images and low confidence without asserting a definite material label.
- Keep all inference offline for the MVP; avoid uploading camera photos or scan history without explicit user opt-in (not planned for v1).
- Do not claim production readiness until end-to-end Android tests have passed.

## Remaining validation before Android v1 release

- Verify that Flutter preprocessing matches the Python pipeline using identical image fixtures.
- Load the model and correct labels from bundled application assets.
- Perform on-device inference and offline functional tests.
- Measure device latency and memory on actual Android hardware.
- Evaluate independently collected smartphone images and document failure modes.
- Add tests for label mapping, low-confidence/error states, camera/gallery input, and SQLite history.
