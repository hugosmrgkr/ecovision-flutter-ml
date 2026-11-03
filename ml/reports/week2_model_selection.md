# EcoVision — Week 2 Model Selection

## Experiment overview

Dataset: TrashNet (six classes)
Training samples: 1766
Validation samples: 378
Test split: Reserved, not evaluated

Backbone: MobileNetV2 pretrained on ImageNet

## Validation results

| Metric | Frozen baseline | Fine-tuning |
|---|---:|---:|
| Accuracy | 85.98% | 87.04% |
| Macro Precision | 83.07% | 84.43% |
| Macro Recall | 82.48% | 81.78% |
| Macro F1 | 82.73% | 82.57% |
| Trash Recall | 57.14% | 42.86% |
| Validation Loss | 0.406878 | 0.373013 |

## Checkpoints

Frozen baseline: `ml/reports/generated/week2/mobilenetv2_frozen_20261103_155149/best_model.keras`

Fine-tuning: `ml/reports/generated/week2/mobilenetv2_finetune_20261103_161943/best_model.keras`

Both checkpoints are local generated artifacts and
are not included in the Git repository.

## Model selection

Selected candidate: Frozen MobileNetV2 baseline, epoch 8.

Rationale:
- Higher macro-F1 than the fine-tuned model.
- Higher recall for the minority trash class.
- Fine-tuning improved overall accuracy and loss,
  but reduced trash recall.
- The fine-tuning experiment remains a comparator.

## Known limitations

- TrashNet has class imbalance.
- Trash is a heterogeneous category.
- Validation results may not represent smartphone photos.
- No independent test-set evaluation has been performed.
- No TensorFlow Lite parity or Android latency results exist yet.

## Next steps

- Preserve both checkpoints and experiment histories.
- Complete reproducibility documentation.
- Continue with model export and final evaluation planning.
