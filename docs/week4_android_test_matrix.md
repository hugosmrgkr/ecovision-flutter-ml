# Pilahin — Week 4 Android Manual QA Checklist

**Status: NOT RUN until executed and recorded by the developer on Android.**

## Device setup (Windows PowerShell)

Use the Flutter SDK in `E:\dev\flutter` explicitly if the PATH still points to the old drive:

```powershell
cd E:\PROJECT\ecovision-flutter-ml\mobile
& 'E:\dev\flutter\bin\flutter.bat' emulators
& 'E:\dev\flutter\bin\flutter.bat' emulators --launch <emulator-id>
& 'E:\dev\flutter\bin\flutter.bat' devices
& 'E:\dev\flutter\bin\flutter.bat' run -d <android-device-id>
```

Replace the placeholders with IDs printed by the commands. For a physical phone, enable Developer Options/USB debugging and authorize the computer, then use its ID. Android camera behavior is best verified on a real phone; an emulator may offer only a virtual camera.

## Test matrix — update after actual run

| ID | Test action | Expected behavior | Result | Evidence/notes |
|---|---|---|---|---|
| A01 | Launch Pilahin on Android | Home renders, no crash/overflow | NOT RUN | |
| A02 | Home -> Scan -> Home | Both routes work and back action works | NOT RUN | |
| A03 | Gallery: select JPG/PNG | Preview and filename shown | NOT RUN | |
| A04 | Gallery: cancel | No crash; previously selected image remains | NOT RUN | |
| A05 | Camera: capture photo | Preview shown, image bytes readable | NOT RUN | |
| A06 | Deny camera access if prompt occurs | Clear recovery/error guidance; app remains usable | NOT RUN | |
| A07 | Remove photo | Preview returns to empty, Analyze disabled | NOT RUN | |
| A08 | Choose invalid/empty/too-large file where supported | Validation message, no crash | NOT RUN | |
| A09 | Mock Analyze -> Result | Photo labeled **not yet AI-analyzed** | NOT RUN | |
| A10 | Expand example result card | Mock label/confidence explicitly marked as demo | NOT RUN | |
| A11 | Scan Lagi | Return to Scan with no previous image | NOT RUN | |
| A12 | History initial state | Empty; not falsely showing user scan records | NOT RUN | |
| A13 | Open demo history, filter by category, open detail | Items and details clearly say DEMO | NOT RUN | |
| A14 | Search no-match then close demo | Empty filter state; returns to empty actual history | NOT RUN | |
| A15 | Guide for six material classes | Cards expand, text remains readable | NOT RUN | |
| A16 | Reopen app in airplane mode after initial install | Offline UI and local image selection remain usable | NOT RUN | |
| A17 | Background/restore during image picker | No crash; handle lost data per plugin behavior | NOT RUN | |
| A18 | Rotate/recreate and narrow display | No major overflow or lost navigation | NOT RUN | |

### Important Android plugin notes

For the existing `image_picker` Android implementation, the package documents no special Android installation configuration for ordinary camera/gallery use; do **not** add blanket photo/storage permissions without a concrete reason. Test camera permission on the target OS and device. On Android, image picker may interrupt the activity, and its `retrieveLostData()` API is provided to recover lost picker results. The project already calls recovery from Scan Screen; its real effectiveness must still be tested on Android.

## Evidence format

Record: Android OS/API level, device model or emulator name, Flutter version, app commit hash, test date, each actual PASS/FAIL/BLOCKED, screenshots or `flutter run` log snippets for issues, and brief reproduction steps. Never replace NOT RUN with PASS by assumption.

## W4 limitations carried to Week 5/6

Real offline model inference, low-confidence model calibration, TensorFlow/TFLite parity on Android, performance benchmarking, and SQLite history persistence are **not** validated here.
