# Pilahin — W4 Day 1 foundation patch

This patch is intended for the **existing** `ecovision-flutter-ml` repository on **Flutter 3.35.5 / Dart 3.9.2**. The public Dart package name stays `ecovision`; the user-facing Flutter app name is Pilahin. The Android launcher label is not changed in this patch.

## Scope

- Material Design 3 light theme and Pilahin color palette.
- App-level GoRouter navigation, ProviderScope bootstrapping.
- Functional Home UI linking to Scan, History, Guide.
- Intentionally honest placeholder pages for Scan, Result, History, Guide (no camera, ML or SQLite functionality claimed).
- Three widget tests replacing the starter counter widget test.

## Local install in Windows PowerShell

1. From repo root check `git status --short`. Backup or review any modified `mobile/lib` or `mobile/test` files first. The supplied patch intentionally replaces the starter `main.dart` and `widget_test.dart`.
2. Extract this archive **into the repository root**, preserving its `mobile/` directory. Use File Explorer Extract All or `Expand-Archive -LiteralPath '...downloaded_zip...' -DestinationPath 'E:\PROJECT\ecovision-flutter-ml' -Force` after replacing the ZIP path with your actual downloaded file path.
3. From `E:\PROJECT\ecovision-flutter-ml\mobile`, install the SDK-compatible exact versions:

```powershell
flutter pub add 'go_router:17.2.3' 'flutter_riverpod:3.3.2'
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

`flutter run -d chrome` is a smoke test for layout and navigation only. The actual target is Android; camera/gallery are not implemented in this patch.

## Key file map

- `mobile/lib/main.dart`: ProviderScope entry point.
- `mobile/lib/app/app.dart`: MaterialApp.router and lifecycle-owned GoRouter.
- `mobile/lib/app/router/app_routes.dart`: route paths.
- `mobile/lib/app/router/app_router.dart`: route mapping.
- `mobile/lib/app/theme/*`: palette and Material 3 theme.
- `mobile/lib/features/home/presentation/screens/home_screen.dart`: Pilahin Home screen.
- `mobile/lib/core/widgets/feature_placeholder.dart`: explicit nonfunctional placeholders.
- `mobile/lib/features/{scan,result,history,guide}/presentation/screens/*`: route entry screens.
- `mobile/test/widget_test.dart`: UI + two navigation tests.

## Expected verification (not yet executed by author)

- `flutter analyze` -> no issues.
- `flutter test` -> 3 tests pass.
- App opens Home page. `Mulai Scan` navigates to Scan; History icon to History; `Panduan Pilah` to Guide.
- Check `git diff` before staging/committing. Do **not** use `git add -A` indiscriminately.

## Known limitations

No real camera or gallery, no mock classifier yet, no true TFLite inference, no SQLite, and no Android device validation. These are future W4/W5/W6 tasks. Riverpod is initialized for later view-models, not used to fake state management on a static page.
