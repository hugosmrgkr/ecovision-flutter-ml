# EcoVision — Week 3 Reproducibility Guide

**Scope:** Restore and verify the preselected frozen MobileNetV2 checkpoint, reproduce its evaluation against fixed test split v1 (when permitted), export float32 TFLite, and validate CPU same-input parity. This guide records the local **observed workflow**; it is not evidence that another machine has rerun it.

## 1. Environment

Observed local configuration:

| Component | Configuration |
|---|---|
| Host | Windows 11, VS Code |
| Linux runtime | WSL2 Ubuntu 24.04.3 LTS |
| Python | 3.12.3 |
| TensorFlow | 2.21.0 |
| GPU | NVIDIA GeForce RTX 3050 Laptop GPU, 4 GB VRAM |
| Python venv | `/home/hugo/.venvs/ecovision-ml` |
| Notebook kernel | `Python (EcoVision ML - WSL GPU)` |
| Repository | `/mnt/e/PROJECT/ecovision-flutter-ml` (Windows `E:\PROJECT\ecovision-flutter-ml`) |

**Dependency records:** `ml/requirements-training-wsl.txt` (Week 2 freeze) and the notebook import list. After later package installations, compare the current environment against this freeze rather than claiming the original freeze reflects every Week 3 addition. Do not blindly reinstall/upgrade TensorFlow or CUDA in the working GPU environment.

Useful environment checks from the activated WSL venv:

```bash
python --version
python -m pip check
python -m pip show tensorflow numpy pandas matplotlib scikit-learn pillow ipykernel
```

The original training notebook was verified with a Jupyter kernel spec whose `LD_LIBRARY_PATH` includes NVIDIA pip library directories and `/usr/lib/wsl/lib`. A plain WSL terminal may not inherit those paths; GPU discovery there may differ from the notebook. GPU acceleration is not required for the **CPU parity** procedure.

## 2. Required local inputs

The public repository should contain the following paths, subject to the project's Git rules:

```text
ml/
  notebooks/
    02_mobilenetv2_baseline.ipynb
    03_model_evaluation.ipynb
    04_tflite_export_and_parity.ipynb
  data/
    splits/v1/train.csv
    splits/v1/val.csv
    splits/v1/test.csv
    splits/v1/metadata.json
  models/v1/
    labels.json
    model_metadata.json
    ecovision_mobilenetv2_float32_v1.tflite
```

Local-only prerequisites, **not** to upload with the public repository:

```text
ml/data/raw/dataset-resized/{cardboard,glass,metal,paper,plastic,trash}/*.jpg
ml/reports/generated/week2/mobilenetv2_frozen_20261103_155149/best_model.keras
```

The `.keras` source checkpoint can be restored from the separately verified Week 2 backup, if needed. The dataset is sourced separately from [TrashNet](https://github.com/garythung/trashnet). Follow the existing split manifests; do not regenerate or relabel them casually.

## 3. Verify integrity before model operations

From the repository root in WSL:

```bash
sha256sum ml/reports/generated/week2/mobilenetv2_frozen_20261103_155149/best_model.keras
sha256sum ml/models/v1/ecovision_mobilenetv2_float32_v1.tflite
python -m json.tool ml/models/v1/labels.json
python -m json.tool ml/models/v1/model_metadata.json
```

Expected hashes:

| File | SHA-256 |
|---|---|
| Frozen Keras checkpoint | `0d560451fbd667f42c852752436a0ffc77f8068b8bd3b326ded4bd16bc3e6023` |
| v1 float32 TFLite | `203947d3ce6b9fcacee91d5827a1ba0cefc2b3cf0207e9ffe1dbd7825f6d1aed` |

Expected labels: `cardboard`, `glass`, `metal`, `paper`, `plastic`, `trash` in that exact order.

**Important:** The model artifacts are versioned: do not silently overwrite the v1 `.tflite` file or `model_metadata.json`. If an updated conversion produces a different checksum, create a new version or explicitly investigate and document why it differs.

## 4. Reproduce/check the final Keras evaluation

Notebook: `ml/notebooks/03_model_evaluation.ipynb`.

1. Open the notebook in VS Code WSL and select `Python (EcoVision ML - WSL GPU)`.
2. Run Sections A–D for environment, label order, split membership, all 380 test SHA-256 hashes, and checkpoint contract checks.
3. Verify **Cell E** uses the identical Week 2 preprocessing:

```python
image_bytes = tf.io.read_file(path)
image = tf.io.decode_image(image_bytes, channels=3, expand_animations=False)
image.set_shape([None, None, 3])
image = tf.image.resize(image, (224, 224), method="bilinear", antialias=True)
image = tf.cast(image, tf.float32)  # pixel range 0..255
# Rescaling to [-1, 1] occurs inside the saved model.
```

4. Keep the **preselected frozen checkpoint**, split, and processing fixed. Do not use the final test outputs for model/threshold selection.
5. Section E performs test inference; F prints metrics; G plots the confusion matrix; H writes the artifacts under `ml/reports/generated/week3/`.
6. **Evaluation was already executed once in the Week 3 developer run.** Re-running for environment verification is different from using test results to tune the model. Preserve the originally reported scores as the frozen v1 final evaluation.

Observed original result: **324/380 accuracy = 85.2632%**, macro-F1 **82.5654%**. Locally generated files:

- `ml/reports/generated/week3/frozen_final_test_metrics.json`
- `ml/reports/generated/week3/frozen_final_test_per_class.csv`
- `ml/reports/generated/week3/frozen_final_test_predictions.csv`
- `ml/reports/generated/week3/frozen_final_test_confusion_matrix.png`

Notebook wall-clock time **20.85 seconds total** included setup/pipeline effects and is **not** Android per-image inference latency.

## 5. TFLite float32 export

Notebook: `ml/notebooks/04_tflite_export_and_parity.ipynb`.

1. Run A to load/verify the frozen checkpoint, label order, input/output contract, and SHA-256.
2. **Cell B is non-idempotent by design:** it refuses to overwrite an existing versioned `.tflite` file. If the exported v1 binary already exists and its hash matches the expected hash above, **skip Cell B**; do not delete the working artifact merely to make the cell pass.
3. Conversion uses `tf.lite.TFLiteConverter.from_keras_model(model)` without quantization/optimization, yielding a float32 model.
4. Output contract verified locally: input `[1,224,224,3]` float32 (dynamic batch signature); output `[1,6]` float32; size **8.513 MiB** (rounded).

## 6. Reproduce CPU parity

This section captures an important developer correction: the *first* parity run mixed Keras GPU with TFLite CPU and failed numerical closeness; a subsequent CPU-to-CPU comparison passed.

1. Use the fixed `val.csv` and select exactly **two images from each of six classes** (12 images total). Verify SHA-256 for each image.
2. Decode RGB and resize with bilinear interpolation and `antialias=True`, retaining float32 pixel values 0–255.
3. **Run Keras on CPU explicitly** in Cell C:

```python
with tf.device("/CPU:0"):
    keras_proba = model(tf.convert_to_tensor(x), training=False).numpy()[0]
```

4. Run TFLite Interpreter on CPU/XNNPACK with **exactly the same** `x` input tensor.
5. Keep the originally defined tolerances: `atol=1e-3`, `rtol=1e-3`. Check all six probability outputs, each sample's top-1 index, and finite/sum-to-one conditions.
6. Observed CPU parity: top-1 **12/12**, max absolute probability difference **3.844e-6**, mean **2.554e-7**, `np.allclose` = **True**, **0/72** outputs outside tolerance.
7. Record the original GPU/CPU discrepancy rather than suppressing it: Keras GPU vs TFLite CPU max difference **0.01034905**, 9/72 outside tolerance; Keras GPU vs Keras CPU max difference **0.01035036**, 9/72 outside tolerance.
8. Run Cell D only after parity passes. It writes `ml/models/v1/model_metadata.json` and Git-ignored `ml/reports/generated/week3/tflite_parity_validation.json`. The developer has confirmed these files were created successfully, but their complete JSON contents were not provided for external inspection in this documentation handoff.

**Reproducibility reminder:** Save the locally updated Cell C before committing `04_tflite_export_and_parity.ipynb`; the downloaded starter notebook initially used GPU-eligible Keras execution. The corrected local notebook should make the intended CPU backend explicit and retain the GPU-versus-CPU observation in documentation.

## 7. Verify generated metadata

Run:

```bash
python -m json.tool ml/models/v1/model_metadata.json
python -m json.tool ml/reports/generated/week3/tflite_parity_validation.json
```

Confirm the actual stored values for model version, checkpoint/TFLite hashes, label order, `atol`, `rtol`, `top1_matches`, max/mean differences, `numeric_allclose`, and CPU backend metadata. **Do not assume a field exists solely because it was proposed in chat**; if metadata needs changes, document them and respect the versioned-artifact guard.

## 8. Before staging any files

```bash
git status --short
git check-ignore -v ml/reports/generated/week3/frozen_final_test_predictions.csv || true
git check-ignore -v ml/data/raw/dataset-resized/cardboard/cardboard1.jpg || true
git diff --check
```

Review untracked `verify_checkpoint.py` in the repo root: it was created as a temporary script. Move any reusable assertions to `ml/tests/` or exclude/remove the temporary file before commit. Review notebook outputs for sensitive/local paths and excessive generated images. The repository should not include raw datasets, local Python environments, personal data, or secrets.

This guide does **not** perform Git staging, commits, or pushes.

## 9. Remaining tests after Week 3

- **Week 4:** Flutter UI, clean architecture, scan/navigation flows and UI states.
- **Week 5:** Bundle TFLite/labels in Flutter, verify exact same-image preprocessing parity and offline inference on Android.
- **Week 6:** SQLite local history, sorting guidance, permissions and invalid/low-confidence handling.
- **Week 7:** Real-device latency, end-to-end test coverage, independent smartphone-photo performance, robustness.
- **Week 8:** README, CI, demo, Android APK release, portfolio assets.
