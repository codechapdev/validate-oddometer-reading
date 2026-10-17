## 0.1.0

- Initial release.
- `OdometerScanner.scan` full-screen capture flow returning a typed `OdometerReading`.
- On-device Laplacian blur pre-check.
- Gemini (REST, structured JSON output) odometer extraction with fraud/quality signals.
- Pluggable business validation rules (`ReadingValidationRule`): previous reading, max reading, min confidence.
- Embeddable `OdometerScannerPage`, `OdometerScannerCubit` and headless analyzer.
