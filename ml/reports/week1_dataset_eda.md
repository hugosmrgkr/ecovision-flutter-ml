# EcoVision — Week 1 TrashNet Dataset Exploration Report

**Project:** EcoVision — AI-Powered Waste Classification Mobile App
**Dataset:** TrashNet (Gary Thung and Mindy Yang)
**Dataset source:** https://github.com/garythung/trashnet
**Review stage:** Week 1, November 2026
**Status:** Baseline data preparation verified locally; labels and similarity review remain provisional.

## 1. Objective

Establish a reproducible six-class image-classification dataset for an offline Flutter + TensorFlow Lite application. The Week 1 workflow covers image-integrity checks, exact-duplicate inspection, visual label review, perceptual-similarity screening, and train/validation/test partitioning. No model has been trained or evaluated yet.

## 2. Dataset inventory

The locally audited copy contains **2,527 readable images** across six classes, with **0 unreadable images**. The counts before and after the documented exclusion of three conflicting-label duplicate copies are:

| Class     | Audited raw copy | Clean manifest |
| --------- | ---------------: | -------------: |
| Cardboard |              403 |            403 |
| Glass     |              501 |            500 |
| Metal     |              410 |            409 |
| Paper     |              594 |            594 |
| Plastic   |              482 |            481 |
| Trash     |              137 |            137 |
| **Total** |        **2,527** |      **2,524** |

The dataset is imbalanced: the paper category contains far more examples than trash. This is an important consideration for macro-F1, recall, and per-class reporting in later model evaluation.

## 3. Exact duplicates and cleaning

A SHA-256 audit identified **3 additional byte-identical copies**, all in pairs with conflicting source class labels:

- `glass/glass115.jpg` and `metal/metal91.jpg`
- `glass/glass176.jpg` and `plastic/plastic152.jpg`
- `glass/glass389.jpg` and `plastic/plastic332.jpg`

After provisional visual review, the clean manifest excludes `metal/metal91.jpg`, `glass/glass176.jpg`, and `plastic/plastic332.jpg`. The retained files are `glass/glass115.jpg`, `plastic/plastic152.jpg`, and `glass/glass389.jpg`. These are image-based decisions, **not independent physical material verification**. The original downloaded dataset has not been modified; the exclusions are recorded in `ml/data/cleaning_decisions.csv`.

The clean manifest contains **2,524 images**, with no repeated SHA-256 hashes.

## 4. Perceptual-similarity review

An 8×8 pHash based on a discrete cosine transform was computed for each clean image. Across **all** pairs of the 2,524 clean images, a Hamming-distance threshold of **6 or less** identified **42 candidate pairs** for visual review.

Manual screenshot-based review recorded:

| Review decision                           | Candidate pairs |
| ----------------------------------------- | --------------: |
| Group (likely same object/capture series) |              32 |
| Different (visually distinct)             |               7 |
| Uncertain, grouped conservatively         |               3 |
| **Total reviewed**                        |          **42** |

The 35 group / uncertain-group relationships were used to construct connected groups for splitting, while the seven visually distinct candidate pairs were not merged. Decisions are stored in `ml/data/global_near_duplicate_review.csv`.

**Scope limitation:** The pHash threshold is a screening heuristic, not proof of identity. Similar items may remain undetected; visually similar images are not necessarily photographs of the same physical object.

## 5. Final group-aware, class-stratified split

The final split was generated using `random_state=42`, stratifying at the **group level** so that the 35 grouped candidate relationships cannot cross train, validation, and test. The clean images were assigned to **2,489 groups**.

| Class     |     Train | Validation |    Test |     Total |
| --------- | --------: | ---------: | ------: | --------: |
| Cardboard |       282 |         61 |      60 |       403 |
| Glass     |       350 |         75 |      75 |       500 |
| Metal     |       287 |         61 |      61 |       409 |
| Paper     |       417 |         88 |      89 |       594 |
| Plastic   |       335 |         72 |      74 |       481 |
| Trash     |        95 |         21 |      21 |       137 |
| **Total** | **1,766** |    **378** | **380** | **2,524** |

- **Train:** 1,766 images (69.97%)
- **Validation:** 378 images (14.98%)
- **Test:** 380 images (15.06%)

All six classes are represented in each partition. The locally executed notebook checks verified that no grouped candidate relationship crosses partitions and no SHA-256 hash is repeated in the clean manifest. Of the 42 visually reviewed pHash candidates, **3 distinct pairs** still cross partitions; these have been reviewed as _different_, not as same-object leakage. No pHash candidates at the specified threshold remain unreviewed.

**Dataset split status:** Approved as the _baseline v1 split under the documented checks_, not certified completely free of all possible near-duplicate leakage.

## 6. Reproducibility and files

- Source of truth: `ml/notebooks/01_dataset_exploration.ipynb` and `ml/src/dataset_audit.py`
- Exclusion decisions: `ml/data/cleaning_decisions.csv`
- Global visual review: `ml/data/global_near_duplicate_review.csv`
- Final split CSVs: `ml/data/splits/v1/{train,val,test}.csv` **once exported to the tracked directory**
- Local generated reports: `ml/reports/generated/` (intentionally excluded from Git)

The split CSVs contain relative image paths and labels, not image bytes. Recreating the dataset requires obtaining TrashNet separately, preserving the class-folder layout, then applying the committed manifest decisions. The repo must not include raw dataset files or local virtual environments.

## 7. Known limitations and next steps

- The source photos generally use controlled backgrounds and do not represent the diversity of smartphone photos in real waste-disposal settings.
- Class imbalance, especially for `trash`, may affect minority-class performance.
- Manual material labels and uncertain pair grouping were inferred from images, not verified against physical objects.
- pHash screening at Hamming distance ≤6 does not detect all possible duplicate or correlated captures.
- Later work should validate image preprocessing and model parity between TensorFlow and TensorFlow Lite, measure inference latency on Android hardware, and evaluate an independent real-world smartphone photo set.
- The test split should remain sealed during model selection and fine-tuning. Use training and validation results for development; use the test set for final reporting.

## 8. Week 1 verification evidence

The developer reported these local runs:

- Python starter unit tests: **4 passed**.
- Flutter `pub get`: successful.
- Flutter static analysis: **No issues found**.
- Flutter starter widget test: **All tests passed**.
- Flutter starter app: successfully launched in Chrome (not yet an Android runtime test).
- TrashNet audit: **2,527 valid**, **0 invalid**, **3 extra exact duplicate copies**.
- Clean image count: **2,524**.
- Final group-aware split: **1,766 train / 378 validation / 380 test**.

These results apply to foundation and dataset checks only. There are **no trained-model accuracy, macro-F1, TensorFlow Lite parity, device latency, or smartphone test results** yet.
