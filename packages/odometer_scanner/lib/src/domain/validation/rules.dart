import 'package:odometer_scanner/src/core/failures.dart';
import 'package:odometer_scanner/src/domain/entities/odometer_analysis.dart';
import 'package:odometer_scanner/src/domain/validation/reading_validation_rule.dart';

class AuthenticImageRule implements ReadingValidationRule {
  const AuthenticImageRule();

  @override
  OdometerFailure? check(OdometerAnalysis a, ValidationContext c) =>
      a.issues.contains(ImageIssue.screenOrEdited)
      ? const SuspiciousImageFailure()
      : null;
}

class OdometerPresenceRule implements ReadingValidationRule {
  const OdometerPresenceRule();

  @override
  OdometerFailure? check(OdometerAnalysis a, ValidationContext c) =>
      !a.isOdometer || a.issues.contains(ImageIssue.notAnOdometer)
      ? const NotAnOdometerFailure()
      : null;
}

class TripMeterRule implements ReadingValidationRule {
  const TripMeterRule();

  @override
  OdometerFailure? check(OdometerAnalysis a, ValidationContext c) =>
      a.issues.contains(ImageIssue.tripMeterOnly)
      ? const TripMeterOnlyFailure()
      : null;
}

class ImageClarityRule implements ReadingValidationRule {
  const ImageClarityRule();

  @override
  OdometerFailure? check(OdometerAnalysis a, ValidationContext c) {
    if (a.issues.contains(ImageIssue.blurry)) return const BlurryImageFailure();
    if (a.issues.contains(ImageIssue.glare) ||
        a.issues.contains(ImageIssue.tooDark)) {
      return PoorLightingFailure(detail: a.remarks);
    }
    if (!a.isImageClear) return const BlurryImageFailure();
    return null;
  }
}

class ReadableDigitsRule implements ReadingValidationRule {
  const ReadableDigitsRule();

  @override
  OdometerFailure? check(OdometerAnalysis a, ValidationContext c) {
    final hidden =
        a.issues.contains(ImageIssue.partiallyVisible) ||
        a.issues.contains(ImageIssue.obstructed);
    return hidden || parseReading(a.reading) == null
        ? const UnreadableReadingFailure()
        : null;
  }
}

class ConfidenceRule implements ReadingValidationRule {
  const ConfidenceRule();

  @override
  OdometerFailure? check(OdometerAnalysis a, ValidationContext c) =>
      a.confidence < c.minConfidence
      ? LowConfidenceFailure(confidencePercent: (a.confidence * 100).round())
      : null;
}

class MaxReadingRule implements ReadingValidationRule {
  const MaxReadingRule();

  @override
  OdometerFailure? check(OdometerAnalysis a, ValidationContext c) {
    final value = parseReading(a.reading);
    return value != null && value > c.maxReading
        ? ReadingOutOfRangeFailure(reading: value, max: c.maxReading)
        : null;
  }
}

class MonotonicReadingRule implements ReadingValidationRule {
  const MonotonicReadingRule();

  @override
  OdometerFailure? check(OdometerAnalysis a, ValidationContext c) {
    final value = parseReading(a.reading);
    final previous = c.previousReading;
    return value != null && previous != null && value < previous
        ? ReadingBelowPreviousFailure(reading: value, previous: previous)
        : null;
  }
}

/// Default ordered rule-set: most fundamental problems are reported first.
const List<ReadingValidationRule> defaultValidationRules = [
  AuthenticImageRule(),
  OdometerPresenceRule(),
  TripMeterRule(),
  ImageClarityRule(),
  ReadableDigitsRule(),
  ConfidenceRule(),
  MaxReadingRule(),
  MonotonicReadingRule(),
];
