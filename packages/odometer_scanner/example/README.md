# odometer_scanner_example

Minimal host app for `odometer_scanner`.

```bash
cd example
flutter create --platforms=android,ios .   # generate platform folders
# add the camera permissions from the package README to ios/Runner/Info.plist
flutter run --dart-define=GEMINI_API_KEY=<your-google-ai-studio-key>
```
