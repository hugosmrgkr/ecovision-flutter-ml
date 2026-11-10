# Pilahin — Week 4 final patch (Day 6 + Day 7)

## What this patch changes

OVERWRITES ONLY:
- `mobile/lib/features/history/presentation/screens/history_screen.dart`
- `mobile/lib/features/guide/presentation/screens/guide_screen.dart`

ADDS:
- `mobile/lib/core/widgets/waste_category_icon.dart`
- `mobile/lib/features/history/domain/entities/scan_history_entry.dart`
- `mobile/lib/features/history/domain/repositories/history_repository.dart`
- `mobile/lib/features/history/data/repositories/demo_history_repository.dart`
- `mobile/lib/features/history/presentation/providers/history_providers.dart`
- `mobile/test/history/history_repository_test.dart`
- `mobile/test/history/history_screen_test.dart`
- `mobile/test/guide/guide_screen_test.dart`
- `mobile/scripts/verify_w4.ps1`
- `docs/week4_*.md`
- `.github/workflows/flutter_w4_checks.yml`

Does not overwrite main.dart, pubspec.yaml, old tests, any ML artifact, or the user's README.

## Apply safely (Windows PowerShell)

1. Exit `flutter run` with `q`.
2. From `E:\PROJECT\ecovision-flutter-ml`, run `git status --short` and back up or commit local W4 changes as appropriate. Do not discard uncommitted work.
3. Extract ZIP into the repository root, **not** the `mobile` directory. Use folder merge; confirm the two existing files listed above before replacing.
4. From `mobile`:

```powershell
cd E:\PROJECT\ecovision-flutter-ml\mobile
& 'E:\dev\flutter\bin\flutter.bat' pub get
& 'E:\dev\flutter\bin\cache\dart-sdk\bin\dart.exe' format lib test
& 'E:\dev\flutter\bin\flutter.bat' analyze
& 'E:\dev\flutter\bin\flutter.bat' test
```

An alternative is `powershell -ExecutionPolicy Bypass -File .\scripts\verify_w4.ps1` (only run after reviewing its content). It does not format automatically.

### Manual UI checks

```powershell
& 'E:\dev\flutter\bin\flutter.bat' run -d chrome
```

- Home -> Riwayat: starts **empty**.
- Tap `Lihat demo tampilan riwayat`: banner clearly says DATA DEMO.
- Try category chips, search, tap a demo record, and close demo.
- Home -> Panduan Pilah: expand all six categories.
- Home -> Scan -> Gallery -> Analyze (Simulasi) -> Result: uploaded image is not falsely labeled as ML inference.

### Android QA

Read `docs/week4_android_test_matrix.md`. Do not claim Android camera or offline inference is tested just because the Chrome UI and widget tests pass.

### Android app launcher name

Inspect `mobile/android/app/src/main/AndroidManifest.xml`. If `<application android:label="ecovision"` still appears, change only the `android:label` value to `Pilahin`. Keep `applicationId`, package name, and namespace unchanged. Check the actual manifest before editing; this patch deliberately does not overwrite it.

## Git review / commit after all relevant tests pass

```powershell
cd E:\PROJECT\ecovision-flutter-ml
git status --short
git diff --check
git diff --stat
```

Review the diff. Do not stage temporary photos, model training datasets, cache, or secrets. Once verified locally:

```powershell
git add mobile/lib mobile/test mobile/scripts mobile/W4_FINAL_INSTALL_AND_TEST.md docs/week4_flutter_ui_and_testing.md docs/week4_android_test_matrix.md docs/week4_handoff_to_week5.md docs/week4_readme_insert.md .github/workflows/flutter_w4_checks.yml
git diff --cached --check
git diff --cached --stat
git commit -m "feat(mobile): finalize Pilahin Week 4 UI and tests"
git push origin main
```

If you edited `pubspec.yaml` or `pubspec.lock` and they are not yet committed, inspect and stage them **explicitly** as well. If your project uses PR branches, open a PR rather than pushing straight to main. Confirm GitHub Actions passes; it is not verified before a push.

## Verified versus pending

Before this patch, developer reported `flutter analyze` clean and 15 tests passed on Day 5. This new patch has **not** been executed on their Flutter SDK or real Android device by this delivery. Do not call W4 final verified until new checks and manual tests are recorded.
