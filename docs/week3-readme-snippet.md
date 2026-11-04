# README insertion snippet — EcoVision Week 3

> **Integration note:** This is a **snippet**, not a replacement for the existing root `README.md`. Add the section below under the project progress / ML model section after reviewing it. This separate file avoids overwriting an existing README whose latest local contents have not been provided.

---

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

---
