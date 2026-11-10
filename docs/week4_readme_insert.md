## Flutter UI — Week 4 (Pilahin)

**Pilahin** is the product name of EcoVision's Android-first Flutter app. Week 4 implements the branded Material 3 screens, `go_router` navigation, `flutter_riverpod` scan state, gallery/camera selection using `image_picker`, validation/preview, and mock-only result UI. The History screen is empty by default, with an opt-in **clearly labeled demonstration list** and category filtering. An offline general-purpose sorting guide covers the six TrashNet material classes.

**Important:** Week 4 does **not** run TFLite inference. Any example labels and confidence values are synthetic UI fixtures, never predictions on a user's photo. Real on-device TFLite inference is planned for Week 5; persisted SQLite history is planned for Week 6.

### Flutter setup

```powershell
cd mobile
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

For Android, run `flutter emulators`, `flutter devices`, and `flutter run -d <android-device-id>` after starting an emulator or connecting a phone. See `docs/week4_android_test_matrix.md` for required real-device verification. See `docs/week4_flutter_ui_and_testing.md` for engineering details and observed-vs-pending test status.
