"""Validate and inventory an unpacked TrashNet folder without mutating it.

Usage:
    python -m ml.src.dataset_audit --data-dir ml/data/raw/trashnet
"""
from __future__ import annotations

import argparse
import csv
import hashlib
import json
from collections import Counter, defaultdict
from pathlib import Path

from PIL import Image, UnidentifiedImageError

LABELS = ("cardboard", "glass", "metal", "paper", "plastic", "trash")
IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp", ".bmp"}
MANIFEST_FIELDS = ("path", "label", "valid", "sha256", "width", "height", "mode", "error")


def audit_dataset(data_dir: Path) -> tuple[dict, list[dict]]:
    """Return a JSON-compatible audit summary and a row-level manifest.

    Content SHA-256 hashes help detect exact duplicates. Near-duplicate or
    visually related photos still require additional review before splitting.
    """
    data_dir = Path(data_dir).expanduser().resolve()
    if not data_dir.is_dir():
        raise FileNotFoundError(f"Dataset directory does not exist: {data_dir}")

    found_dirs = {p.name for p in data_dir.iterdir() if p.is_dir()}
    missing_classes = sorted(set(LABELS) - found_dirs)
    unexpected_dirs = sorted(found_dirs - set(LABELS))
    rows: list[dict] = []
    skipped_files: list[str] = []
    hash_to_paths: dict[str, list[str]] = defaultdict(list)

    for label in LABELS:
        class_dir = data_dir / label
        if not class_dir.is_dir():
            continue
        for path in sorted(class_dir.rglob("*")):
            if not path.is_file():
                continue
            relative = path.relative_to(data_dir).as_posix()
            if path.suffix.lower() not in IMAGE_EXTENSIONS:
                skipped_files.append(relative)
                continue
            row = {
                "path": relative,
                "label": label,
                "valid": False,
                "sha256": "",
                "width": "",
                "height": "",
                "mode": "",
                "error": "",
            }
            try:
                with Image.open(path) as img:
                    width, height = img.size
                    mode = img.mode
                    img.verify()
                digest = hashlib.sha256(path.read_bytes()).hexdigest()
                row.update(valid=True, sha256=digest, width=width, height=height, mode=mode)
                hash_to_paths[digest].append(relative)
            except (OSError, ValueError, UnidentifiedImageError) as exc:
                row["error"] = f"{type(exc).__name__}: {exc}"
            rows.append(row)

    counts = Counter(row["label"] for row in rows if row["valid"])
    duplicate_groups = [sorted(paths) for paths in hash_to_paths.values() if len(paths) > 1]
    duplicate_groups.sort()
    invalid = [row["path"] for row in rows if not row["valid"]]
    summary = {
        "dataset": "TrashNet (local audit)",
        "classes": list(LABELS),
        "class_counts": {label: counts[label] for label in LABELS},
        "total_files_with_image_extensions": len(rows),
        "valid_images": sum(counts.values()),
        "invalid_images": invalid,
        "missing_classes": missing_classes,
        "unexpected_dirs": unexpected_dirs,
        "skipped_non_image_files": skipped_files,
        "exact_duplicate_groups": duplicate_groups,
        "exact_duplicate_extra_copies": sum(len(paths) - 1 for paths in duplicate_groups),
        "integrity_passed": (
            len(rows) > 0
            and not missing_classes
            and not unexpected_dirs
            and not invalid
            and not duplicate_groups
        ),
        "notes": [
            "SHA-256 detects byte-identical images, not resized/cropped/near duplicates.",
            "Inspect labels and potential data leakage manually before splitting.",
            "The original TrashNet distribution is imbalanced and has simple backgrounds.",
        ],
    }
    return summary, rows


def write_reports(summary: dict, rows: list[dict], report_dir: Path) -> None:
    report_dir = Path(report_dir)
    report_dir.mkdir(parents=True, exist_ok=True)
    (report_dir / "dataset_audit.json").write_text(
        json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    with (report_dir / "dataset_manifest.csv").open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=MANIFEST_FIELDS)
        writer.writeheader()
        writer.writerows(rows)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--data-dir", type=Path, default=Path("ml/data/raw/trashnet"))
    parser.add_argument("--reports-dir", type=Path, default=Path("ml/reports/generated"))
    args = parser.parse_args()
    try:
        summary, rows = audit_dataset(args.data_dir)
    except FileNotFoundError as exc:
        parser.error(str(exc))
    write_reports(summary, rows, args.reports_dir)
    print(json.dumps({
        "valid_images": summary["valid_images"],
        "class_counts": summary["class_counts"],
        "invalid_images": len(summary["invalid_images"]),
        "exact_duplicate_extra_copies": summary["exact_duplicate_extra_copies"],
        "missing_classes": summary["missing_classes"],
        "integrity_passed": summary["integrity_passed"],
    }, indent=2))
    return 0 if summary["integrity_passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
