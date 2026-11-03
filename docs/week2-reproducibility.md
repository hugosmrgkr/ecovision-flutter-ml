# EcoVision — Week 2 ML Reproducibility

## 1. Overview

Week 2 focused on training and evaluating a six-class waste image classifier using MobileNetV2 transfer learning.

Two experiments were completed:

1. Frozen MobileNetV2 baseline.
2. Controlled MobileNetV2 fine-tuning.

All reported metrics are based on the validation split. The independent test split remains reserved for final evaluation.

## 2. Development Environment

| Component | Configuration |
|---|---|
| Operating System | Windows 11 + Ubuntu 24.04.3 LTS (WSL2) |
| Python | 3.12.3 |
| TensorFlow | 2.21.0 |
| GPU | NVIDIA GeForce RTX 3050 Laptop GPU |
| GPU VRAM | 4 GB |
| Editor | Visual Studio Code |
| Notebook | Jupyter Notebook |
| Python Environment | `~/.venvs/ecovision-ml` |

TensorFlow GPU support was verified through matrix multiplication and execution inside a VS Code Jupyter Notebook using WSL2.

The Python dependency snapshot is stored in:

`ml/requirements-training-wsl.txt`

## 3. Dataset

**Dataset:** TrashNet

**Authors:** Gary Thung and Mindy Yang

**Source:** https://github.com/garythung/trashnet

The cleaned Week 1 dataset contains 2,524 images across six classes.

| Split | Images |
|---|---:|
| Training | 1,766 |
| Validation | 378 |
| Test | 380 |
| **Total** | **2,524** |

Supported classes:

- cardboard
- glass
- metal
- paper
- plastic
- trash

The dataset manifests are stored in:

`ml/data/splits/v1/`

During Week 2, all 2,144 training and validation images were verified against the SHA-256 hashes recorded in the manifests.

**Verification results:**

- Images checked: 2,144
- SHA-256 mismatches: 0
- Training/validation exact-hash overlap: 0
- Training/validation group overlap: 0

The local image directory used for training was:

`ml/data/raw/dataset-resized/`

Raw dataset images are excluded from Git.

## 4. Environment Setup

The ML training environment runs inside Ubuntu WSL2.

Create and activate a Python environment:

```bash
python3 -m venv ~/.venvs/ecovision-ml
source ~/.venvs/ecovision-ml/bin/activate
```

Install the recorded dependencies:

```bash
python -m pip install -r ml/requirements-training-wsl.txt
python -m pip check
```

Register the Jupyter kernel:

```bash
python -m ipykernel install --user \
  --name ecovision-ml \
  --display-name "Python (EcoVision ML - WSL GPU)"
```

On the development machine, NVIDIA CUDA library directories were added to the `LD_LIBRARY_PATH` environment variable in the Jupyter kernelspec.

This configuration may require adjustment on other systems.

Verify GPU detection in the notebook:

```python
import tensorflow as tf

print("TensorFlow:", tf.__version__)
print("GPU devices:", tf.config.list_physical_devices("GPU"))
```

GPU detection should also be followed by an actual GPU computation test.

The dependency snapshot represents the verified development environment and does not guarantee identical results across all machines.

## 5. Model Architecture

**Architecture:** MobileNetV2

**Pretrained weights:** ImageNet

**Classification task:** Six-class single-image classification

**Input contract:**

- Input shape: `[1, 224, 224, 3]`
- Input dtype: float32
- Color format: RGB
- Input pixel range: 0–255
- Normalization: Rescaling to [-1, 1] inside the model
- Output: Six softmax probabilities

**Classification head:**

1. MobileNetV2 feature extractor
2. Global Average Pooling
3. Dropout (0.2)
4. Dense layer with six softmax outputs

The baseline model contains:

- Total parameters: 2,265,670
- Trainable parameters: 7,686
- Frozen parameters: 2,257,984

## 6. Training Pipeline

Training notebook:

`ml/notebooks/02_mobilenetv2_baseline.ipynb`

The data pipeline uses TensorFlow `tf.data`.

**Image preprocessing:**

- Decode images as RGB
- Resize to 224 × 224
- Convert to float32
- Preserve pixel values within 0–255

**Training-only augmentation:**

- Random horizontal flip
- Random rotation
- Random zoom

Validation images are not augmented.

The independent test split was not used for training, fine-tuning, checkpoint selection, or validation analysis.

## 7. Experiment 01 — Frozen MobileNetV2 Baseline

**Experiment ID:**

`mobilenetv2_frozen_20261103_155149`

**Configuration:**

| Parameter | Value |
|---|---|
| Backbone | MobileNetV2 |
| Backbone status | Frozen |
| Optimizer | Adam |
| Learning rate | 0.001 |
| Batch size | 8 |
| Maximum epochs | 12 |
| Best checkpoint epoch | 8 |
| Selection metric | Minimum validation loss |

**Validation results:**

| Metric | Result |
|---|---:|
| Accuracy | 85.98% |
| Macro Precision | 83.07% |
| Macro Recall | 82.48% |
| Macro-F1 | 82.73% |
| Trash Recall | 57.14% |
| Validation Loss | 0.406878 |

Correct predictions: 325 of 378 validation images.

The best checkpoint was successfully reloaded and evaluated.

Checkpoint:

`ml/reports/generated/week2/mobilenetv2_frozen_20261103_155149/best_model.keras`

## 8. Experiment 02 — Controlled Fine-Tuning

**Experiment ID:**

`mobilenetv2_finetune_20261103_161943`

Fine-tuning was initialized using the best frozen baseline checkpoint.

**Configuration:**

| Parameter | Value |
|---|---|
| Starting model | Frozen baseline, epoch 8 |
| Backbone | MobileNetV2 |
| Fine-tuning | Selected upper 20 layers |
| BatchNormalization | Kept frozen |
| Optimizer | Adam |
| Learning rate | 0.00001 |
| Batch size | 4 |
| Maximum epochs | 8 |
| Best checkpoint epoch | 7 |
| Selection metric | Minimum validation loss |

Trainable parameters: 1,202,566.

**Validation results:**

| Metric | Result |
|---|---:|
| Accuracy | 87.04% |
| Macro Precision | 84.43% |
| Macro Recall | 81.78% |
| Macro-F1 | 82.57% |
| Trash Recall | 42.86% |
| Validation Loss | 0.373013 |

Correct predictions: 329 of 378 validation images.

Checkpoint:

`ml/reports/generated/week2/mobilenetv2_finetune_20261103_161943/best_model.keras`

## 9. Model Comparison

| Metric | Frozen Baseline | Fine-Tuning |
|---|---:|---:|
| Accuracy | 85.98% | 87.04% |
| Macro Precision | 83.07% | 84.43% |
| Macro Recall | 82.48% | 81.78% |
| Macro-F1 | 82.73% | 82.57% |
| Trash Recall | 57.14% | 42.86% |
| Validation Loss | 0.406878 | 0.373013 |

Fine-tuning improved overall validation accuracy and reduced validation loss.

However, its macro-F1 decreased slightly, and the minority trash-class recall decreased from 57.14% to 42.86%.

On the validation set:

- Frozen baseline correctly classified 12 of 21 trash images.
- Fine-tuning correctly classified 9 of 21 trash images.
- Three previously correct trash predictions became incorrect after fine-tuning.
- No previously incorrect trash predictions became correct.

### Provisional Model Selection

**Selected candidate: Frozen MobileNetV2 baseline, epoch 8.**

Selection rationale:

- Higher validation macro-F1.
- Higher recall for the minority trash class.
- Better balance for the six-class classification objective.

The fine-tuned model is retained as a comparison checkpoint.

This selection is provisional and does not represent independent test-set performance.

See:

`ml/reports/week2_model_selection.md`

## 10. Error Analysis

Validation error analysis identified two important patterns.

### Plastic vs Glass

Nine plastic images were incorrectly classified as glass.

Several misclassified images contained transparent bottles, reflective surfaces, or visually similar packaging.

These observations suggest potential visual ambiguity between transparent plastic and glass.

### Trash Classification

The trash category showed weaker performance than other classes.

TrashNet includes heterogeneous objects in this category, some of which visually resemble plastic, paper, cardboard, or metal.

This introduces a limitation in the semantic definition of the trash class.

The findings do not establish that all classification errors result from class imbalance or ambiguous materials.

## 11. Experiment Artifacts and Backups

Generated experiment outputs are stored locally under:

`ml/reports/generated/week2/`

This directory is excluded from Git.

Frozen baseline checkpoint size: approximately 9.3 MB.

Fine-tuning checkpoint size: approximately 19 MB.

Local backups were created at:

`D:\EcoVisionModelBackups\week2\`

Backup filenames:

- `frozen_baseline.keras`
- `fine_tuning.keras`
- `02_mobilenetv2_with_outputs.ipynb`

Both model backups were verified using SHA-256 and matched their source checkpoints.

The public notebook had its execution outputs removed while preserving its source code and Markdown cells.

The original checkpoints are not distributed through the GitHub repository.

Re-running the notebook may produce different results because of execution-environment and numerical differences.

## 12. Known Limitations

- The TrashNet dataset is class-imbalanced.
- The trash category contains visually heterogeneous objects.
- Validation results do not guarantee real-world smartphone performance.
- Independent test-set evaluation has not been completed.
- TensorFlow Lite conversion has not been completed.
- TensorFlow and TensorFlow Lite inference parity has not been verified.
- Android inference latency has not been measured.
- Confidence-score calibration has not been evaluated.
- The Flutter application MVP is not yet implemented.

## 13. Week 3 Handoff

The next development phase will focus on model evaluation and mobile deployment preparation.

Planned tasks:

1. Preserve both Week 2 checkpoints.
2. Finalize the versioned label mapping and model contract.
3. Perform independent test-set evaluation using the selected candidate.
4. Export the model to TensorFlow Lite.
5. Verify TensorFlow vs TensorFlow Lite inference parity.
6. Measure model size and inference latency.
7. Document results, limitations, and deployment readiness.

All evaluation results must come from actual experiments.

No unverified accuracy, latency, model-size benchmark, or Android performance claims should be reported.

---

**Week 2 Status:** Training and validation experiments completed. Frozen MobileNetV2 epoch 8 selected as the provisional candidate for Week 3.wc -l docs/week2-reproducibility.md
git status --short