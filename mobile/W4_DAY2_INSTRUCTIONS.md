# Pilahin W4 Day 2 — Beranda UI refinement

## Scope
- Replace only `mobile/lib/features/home/presentation/screens/home_screen.dart`.
- Add `mobile/lib/features/home/presentation/widgets/home_illustration.dart`.
- All other application files, `pubspec.yaml`, ML artifacts, and existing tests remain unchanged.
- Uses Material 3 and the existing Pilahin palette. Illustration is rendered with Flutter widgets (not a screenshot asset).
- Preserves the same route calls for Scan, Guide, and History; no extra packages required.

## Applying patch (Windows)
1. Save a backup or commit your current changes before overwriting. From repo root, run `git status --short`.
2. Extract the ZIP into `E:\PROJECT\ecovision-flutter-ml` (the repository **root**), preserving `mobile/` paths and replacing only the matching `home_screen.dart`.
3. From `E:\PROJECT\ecovision-flutter-ml\mobile` run:

```powershell
dart format lib/features/home/presentation/screens/home_screen.dart lib/features/home/presentation/widgets/home_illustration.dart
flutter analyze
flutter test
flutter run -d chrome
```

4. On Chrome, narrow the browser to approximate a phone, inspect the Home layout, scroll to the six category chips, and check Home -> Scan, Guide, History navigation and back actions.

## Important notes
- Author couldn't run Flutter in this environment; results must be verified on your Windows machine. Do not claim tests passed until the commands above succeed.
- Offline AI inference and camera/gallery are not part of this patch. Flutter Android runtime will be tested later.
- If any layout overflows on a very narrow phone, report the screen size and screenshot before changing UI constraints.
