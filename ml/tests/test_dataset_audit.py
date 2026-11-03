"""Unit tests use synthetic images; the TrashNet dataset is not required."""
from pathlib import Path

from PIL import Image

from ml.src.dataset_audit import LABELS, audit_dataset, write_reports


def make_images(base: Path) -> None:
    for index, label in enumerate(LABELS):
        class_dir = base / label
        class_dir.mkdir(parents=True)
        Image.new("RGB", (8, 8), (index * 25, 100, 200)).save(class_dir / "sample.png")


def test_clean_dataset(tmp_path: Path) -> None:
    make_images(tmp_path)
    summary, rows = audit_dataset(tmp_path)
    assert summary["integrity_passed"] is True
    assert summary["valid_images"] == 6
    assert all(summary["class_counts"][label] == 1 for label in LABELS)
    assert len(rows) == 6


def test_exact_duplicate_is_reported(tmp_path: Path) -> None:
    make_images(tmp_path)
    source = tmp_path / "cardboard" / "sample.png"
    target = tmp_path / "glass" / "sample.png"
    target.write_bytes(source.read_bytes())
    summary, _ = audit_dataset(tmp_path)
    assert summary["integrity_passed"] is False
    assert summary["exact_duplicate_extra_copies"] == 1


def test_missing_class_and_invalid_image(tmp_path: Path) -> None:
    (tmp_path / "glass").mkdir()
    (tmp_path / "glass" / "bad.jpg").write_bytes(b"not an image")
    summary, rows = audit_dataset(tmp_path)
    assert "plastic" in summary["missing_classes"]
    assert summary["invalid_images"] == ["glass/bad.jpg"]
    assert not rows[0]["valid"]


def test_write_reports(tmp_path: Path) -> None:
    images = tmp_path / "dataset"
    images.mkdir()
    make_images(images)
    summary, rows = audit_dataset(images)
    out = tmp_path / "reports"
    write_reports(summary, rows, out)
    assert (out / "dataset_audit.json").exists()
    assert (out / "dataset_manifest.csv").exists()
