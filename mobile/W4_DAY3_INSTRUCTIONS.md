# Pilahin — Week 4 Day 3: camera, gallery, image preview

## Scope and existing project

This patch adds `ScanImage` entity, repository interface, `image_picker` adapter, Riverpod view model, Scan screen and isolated unit tests. It does **not** change `pubspec.yaml`, `main.dart`, Home screen, navigation routes, ML assets or SQLite. The existing Flutter package name remains `ecovision`; the displayed app brand is Pilahin.

The patch uses the exact previously verified source layout. Do not extract over a dirty tree without reviewing changes first. Run `git status --short` at the repo root before applying.

## Apply from Windows PowerShell

1. Extract ZIP into `E:\PROJECT\ecovision-flutter-ml` (not into `mobile/mobile`). It replaces only `mobile/lib/features/scan/presentation/screens/scan_screen.dart`; other Dart files are new.
2. Install the pinned SDK-compatible package from `mobile/`:

```powershell
flutter pub add 'image_picker:1.2.2'
```

3. Format and verify:

```powershell
dart format lib test
flutter analyze
flutter test
flutter run -d chrome
```

The `image_picker:1.2.2` release specifies minimum Flutter 3.35/Dart 3.9; your verified Flutter 3.35.5 and Dart 3.9.2 meet these. Do not run a broad `pub upgrade --major-versions`.

## Manual smoke test in Chrome

- Open Beranda -> Mulai Scan.
- Check `Pilih gambar untuk dianalisis`, preview placeholder, `Kamera`, `Galeri` and disabled `Analisis` button.
- Click `Galeri`; pick a JPG/PNG. The image should preview and its name appear.
- Click `Hapus`: preview resets. Cancel picker: previous image should remain.
- Pick invalid/corrupt file or a >20 MB image: friendly error state should appear.

Browser camera behavior varies by browser/platform: do not treat Chrome web as validation of Android camera permissions. An Android device/emulator is required for real camera and gallery testing. Use `flutter devices` to confirm a target before `flutter run -d <device-id>`.

On Android, `image_picker` usually requires no manual manifest permissions; the plugin uses system intents/photo picker. Android can kill the host activity while picker is open: this patch requests recovery when Scan screen is first shown, but robust app-start recovery and durable storage are future hardening tasks. Picked camera files are in temporary cache; permanent storage comes with Week 6 history.

## Testing constraints

Three new unit tests cover: picker cancelled, selected image, and picker error state. Existing widget tests should remain in place (including the Day 2 `tester.ensureVisible` fix). `flutter test` expected total is **6** tests if original 3 tests remain. This count is a target, not a test result from the user machine.

## Known limitations

- No real ML inference in Week 4 Day 3; analysis CTA intentionally disabled until Day 4 mock workflow.
- Images are kept only in memory and capped at 20 MB.
- `image_picker` camera on web is browser-dependent; Android must be validated separately.
- Test method `testWidgets` UI routes remains from Day 2; Day 3 adds provider tests rather than changing navigation code.
- If an Android platform permission error occurs, state surfaces a friendly generic message. Exact permission cases must be verified on device.
