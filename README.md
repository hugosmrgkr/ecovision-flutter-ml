# EcoVision — AI-Powered Waste Classification Mobile App

EcoVision is an Android-first Flutter application intended to classify the dominant waste material in a photo, using an independently trained TensorFlow Lite image classifier running **offline**.

> **Project status (November 2026):** Week 1 dataset
> preparation and Week 2 MobileNetV2 training are completed.
> Two models have been trained and evaluated on the validation
> set. The Flutter starter scaffold exists, but the MVP,
> TensorFlow Lite integration, and Android inference are
> not yet implemented. Independent test-set evaluation
> has not been performed.

## Planned MVP

- Capture a photo or select one from the gallery.
- Predict one of six labels: `cardboard`, `glass`, `metal`, `paper`, `plastic`, `trash`.
- Display predicted label, confidence, and basic sorting guidance.
- Store scan history locally with SQLite.
- Support offline inference and handle camera permissions, invalid inputs, and low-confidence results.

## Tech stack (planned)

- **Mobile:** Flutter, Dart, Riverpod, MVVM, Repository Pattern, go_router, Material 3, SQLite.
- **ML:** Python, Jupyter, TensorFlow/Keras, MobileNetV2, TensorFlow Lite.
- **Data:** TrashNet, with real-world smartphone photos reserved for later evaluation.

## Week 1 quick start (Windows PowerShell)

Prerequisites: Git, VS Code, Python 3.11, Flutter SDK and Android SDK. Check versions with `python --version`, `py -0p`, `flutter doctor -v`, and `git --version` before installing additional software.

From this repository directory:

```powershell
py -3.11 -m venv .venv
.\.venv\Scripts\python.exe -m pip install --upgrade pip
.\.venv\Scripts\python.exe -m pip install -r ml\requirements-exploration.txt
.\.venv\Scripts\python.exe -m pytest ml\tests -q
```

In VS Code, install Python and Jupyter extensions and select the `.venv` kernel for `ml/notebooks/01_dataset_exploration.ipynb`.

After installing Flutter and Android SDK:

```powershell
flutter doctor -v
flutter doctor --android-licenses
cd mobile
flutter pub get
flutter analyze
flutter test
flutter run
```

`flutter run` requires a running Android emulator or connected Android phone. Flutter commands should be run from **Windows PowerShell**, not WSL2; WSL2 is reserved for GPU training when configured.

## Obtain dataset

Source: https://github.com/garythung/trashnet

1. Download `data/dataset-resized.zip` from the original TrashNet repository.
2. Extract it locally so the six folders exist at `ml/data/raw/trashnet/<class-name>/` (rename the extracted `dataset-resized` folder to `trashnet`).
3. Do not add raw images to Git.
4. Run the exploration notebook. It creates `ml/reports/generated/dataset_audit.json` and `dataset_manifest.csv` locally.

See [ml/data/README.md](ml/data/README.md) for attribution and limitations and [docs/week1-checklist.md](docs/week1-checklist.md) for acceptance criteria.

## Repository layout

```text
ecovision-flutter-ml/
├── mobile/                  #  # Flutter starter scaffold
├── ml/
│   ├── notebooks/           # Jupyter EDA
│   ├── src/                 # reusable Python logic
│   ├── tests/               # dataset audit unit tests
│   ├── data/                # dataset instructions; raw data ignored by Git
│   └── reports/             # generated reports ignored by Git
├── docs/                    # technical contracts and notes
├── .vscode/                 # recommended extensions
├── .gitignore
└── README.md
```

## Engineering commitments

- Keep train/validation/test splits independent; deduplicate **before** splitting.
- Do not fit transforms on validation/test data or augment outside training.
- Document data provenance, evaluation metrics, TensorFlow–TFLite parity, device latency and model size when those tests have actually been run.
- Do not put secrets, personal photos, or raw TrashNet images in the public repository.

## Attribution

TrashNet dataset: Gary Thung and Mindy Yang, *Classification of Trash for Recyclability Status* (Stanford CS229, 2016). https://github.com/garythung/trashnet

## Machine Learning — Week 3: Final Evaluation and TFLite Export

EcoVision's first mobile-ready **candidate** is a MobileNetV2 six-class image classifier trained with a frozen ImageNet backbone. The checkpoint was selected using validation results before an independent TrashNet test evaluation.

| Metric | Observed result |
|---|---:|
| TrashNet test images | 380 |
| Frozen Keras test accuracy | **85.26%** (324/380) |
| Macro precision / recall / F1 | 82.45% / 83.03% / **82.57%** |
| `trash` class recall | 66.67% (14/21) |
| Float32 TFLite model size | **8.513 MiB** |
| Keras CPU vs TFLite CPU top-1 parity | **12/12** validation samples |
| Keras CPU vs TFLite CPU numeric tolerance | **Passed**, `atol=rtol=1e-3` |

Input contract: **RGB 224×224, float32, pixel values 0–255**; the model rescales to [-1,1] internally. Output is a six-class softmax vector ordered `cardboard`, `glass`, `metal`, `paper`, `plastic`, `trash`.

Technical documentation:

- [Week 3 final evaluation report](ml/reports/week3_model_evaluation.md)
- [Model card v1](docs/model-card-v1.md)
- [Week 3 reproducibility guide](docs/week3-reproducibility.md)
- [Week 3 technical handoff](docs/week3-handoff.md)

**Limitations:** These test metrics were measured on the frozen **Keras** model, not on an Android app. TensorFlow GPU and TFLite CPU outputs showed larger numerical differences than CPU-to-CPU outputs; the validated parity check uses the **same CPU backend** for both runtimes. Flutter preprocessing parity, real-device latency, offline end-to-end behavior, and independent smartphone-photo accuracy are pending.
