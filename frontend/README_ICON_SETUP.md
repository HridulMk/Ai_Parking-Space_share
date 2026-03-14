App Icon Setup

This project includes a placeholder icon asset at `assets/icon/app_icon.svg`.

To generate platform launcher icons (recommended):

1. Add a proper 1024x1024 PNG to `assets/icon/app_icon.png` (replace placeholder).
2. Install packages and run the launcher icon generator:

```bash
flutter pub get
flutter pub run flutter_launcher_icons:main
```

The `pubspec.yaml` is already configured with `flutter_launcher_icons` settings.

Notes:
- The generator requires a PNG at `assets/icon/app_icon.png`.
- After running the command, verify icons under `android/app/src/main/res` and iOS asset catalogs.
- For Windows/macOS/linux desktop, you may need to set the icon manually using platform-specific resources.

If you want, I can:
- Generate multiple icon sizes and add them to the project (you'll need to provide a PNG), or
- Guide you step-by-step to create a PNG from the included SVG.
