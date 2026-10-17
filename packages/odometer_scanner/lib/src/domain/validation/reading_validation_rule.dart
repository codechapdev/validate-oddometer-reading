import 'package:odometer_scanner/src/core/failures.dart';
import 'package:odometer_scanner/src/domain/entities/odometer_analysis.dart';

class ValidationContext {
  const ValidationContext({
    required this.minConfidence,
    required this.maxReading,
    this.previousReading,
  });

  final double minConfidence;
  final int maxReading;
  final int? previousReading;
}

/// A single, independent business rule. New rules can be added without
/// modifying existing ones (Open/Closed principle).
abstract interface class ReadingValidationRule {
  /// Returns a failure when the rule is violated, otherwise `null`.
  OdometerFailure? check(OdometerAnalysis analysis, ValidationContext context);
}

/// Parses the AI reading into an integer, ignoring separators.
int? parseReading(String? raw) {
  if (raw == null) return null;
  final digits = raw.replaceAll(RegExp(r'[\s,. ]'), '');
  if (digits.isEmpty || !RegExp(r'^\d+$').hasMatch(digits)) return null;
  return int.tryParse(digits);
}
