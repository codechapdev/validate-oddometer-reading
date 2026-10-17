# Odometer Reading POC

Host app demonstrating the reusable [`odometer_scanner`](packages/odometer_scanner) module (Flutter · Clean Architecture · Cubit · Gemini).

## Run

```bash
flutter pub get
flutter run --dart-define=GEMINI_API_KEY=<your-google-ai-studio-key>
# optional: --dart-define=GEMINI_MODEL=<model-id>
```

Get a key at https://aistudio.google.com/apikey.

## Test

```bash
flutter test && (cd packages/odometer_scanner && flutter test)
```
