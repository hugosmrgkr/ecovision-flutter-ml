# Model contract — planned baseline (not yet tested)

- Architecture: MobileNetV2 (ImageNet transfer learning)
- Classification: dominant single-object waste material
- Input tensor: `[1, 224, 224, 3]`
- Input dtype: `float32`
- Input channel order: `RGB`
- Input pixel range: `[0, 255]`
- Scaling: normalize to `[-1, 1]` **inside** the exported model
- Output: six probabilities, aligned with a versioned `labels.json`
- Label order: `cardboard`, `glass`, `metal`, `paper`, `plastic`, `trash` (to be enforced at training and inference)
- Initial split target: 70% train / 15% validation / 15% test, before any augmentation and after leakage assessment

**Required future verification:** same-image TensorFlow vs TensorFlow Lite output parity, class mapping, input preprocessing, invalid-image behavior, real-device inference latency, size and real-world performance.

No model is included in this Week 1 scaffold.
