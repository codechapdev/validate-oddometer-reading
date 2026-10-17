import 'package:flutter/material.dart';
import 'package:odometer_scanner/src/core/odometer_scanner_config.dart';
import 'package:odometer_scanner/src/di/odometer_scanner_dependencies.dart';
import 'package:odometer_scanner/src/domain/entities/odometer_reading.dart';
import 'package:odometer_scanner/src/presentation/pages/odometer_scanner_page.dart';

/// Single entry point (facade) for host apps.
///
/// ```dart
/// final reading = await OdometerScanner.scan(
///   context,
///   config: OdometerScannerConfig(geminiApiKey: key, previousReading: 42000),
/// );
/// ```
abstract final class OdometerScanner {
  /// Opens the scanner and resolves with the confirmed reading, or `null`
  /// if the user backs out.
  static Future<OdometerReading?> scan(
    BuildContext context, {
    required OdometerScannerConfig config,
    OdometerScannerDependencies? dependencies,
    String title = 'Scan odometer',
  }) => Navigator.of(context).push<OdometerReading>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => OdometerScannerPage(
        config: config,
        dependencies: dependencies,
        title: title,
      ),
    ),
  );
}
