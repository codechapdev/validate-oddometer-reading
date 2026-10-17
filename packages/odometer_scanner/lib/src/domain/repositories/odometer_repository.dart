import 'package:odometer_scanner/src/core/result.dart';
import 'package:odometer_scanner/src/domain/entities/captured_image.dart';
import 'package:odometer_scanner/src/domain/entities/odometer_analysis.dart';

/// Abstraction over whichever engine extracts the reading (Gemini today,
/// possibly an on-device model tomorrow).
abstract interface class OdometerRepository {
  Future<Result<OdometerAnalysis>> analyze(CapturedImage image);
}
