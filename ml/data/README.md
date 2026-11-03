# TrashNet data (not committed)

**Origin:** Gary Thung and Mindy Yang, *Classification of Trash for Recyclability Status*, Stanford CS229 (2016). Repository: https://github.com/garythung/trashnet

The upstream repository describes **2,527 images** across six classes: cardboard (403), glass (501), metal (410), paper (594), plastic (482), trash (137). These are source-reported figures, not EcoVision audit results.

Download `data/dataset-resized.zip` from upstream. Extract locally to:

```text
ml/data/raw/trashnet/
├── cardboard/
├── glass/
├── metal/
├── paper/
├── plastic/
└── trash/
```

The raw dataset folder is excluded by `.gitignore`; do not commit the zip or raw images. Review upstream terms before redistributing any dataset material.

## Known risks to assess

- Simple backgrounds and controlled lighting may not reflect actual phone-camera conditions.
- `trash` is relatively underrepresented (137 images, per upstream).
- Exact duplicate checks do not catch near duplicates or similar captures of the same object.
- Split 70/15/15 **only after** manual review and deduplication; keep related photos in a single split.
- Reserve a separate smartphone-photo test set; do not use it for model tuning.

Run from repository root:

```powershell
.\.venv\Scripts\python.exe -m ml.src.dataset_audit --data-dir ml/data/raw/trashnet
```

The audit exits with code 1 when it detects structural/integrity issues; investigate those issues before using the data.
