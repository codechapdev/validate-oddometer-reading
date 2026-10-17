import 'package:equatable/equatable.dart';

enum DistanceUnit {
  kilometers('km'),
  miles('mi'),
  unknown('');

  const DistanceUnit(this.symbol);

  final String symbol;
}

enum OdometerDisplayType { digital, analog, unknown }

/// Problems the AI may detect in a photo.
enum ImageIssue {
  blurry,
  glare,
  tooDark,
  partiallyVisible,
  obstructed,
  notAnOdometer,
  tripMeterOnly,
  screenOrEdited,
}

/// Raw, un-validated outcome of analysing an odometer photo.
class OdometerAnalysis extends Equatable {
  const OdometerAnalysis({
    required this.isOdometer,
    required this.isImageClear,
    required this.reading,
    required this.unit,
    required this.displayType,
    required this.confidence,
    required this.issues,
    this.remarks,
  });

  final bool isOdometer;
  final bool isImageClear;

  /// Digits exactly as read, or `null` if they could not be read.
  final String? reading;
  final DistanceUnit unit;
  final OdometerDisplayType displayType;

  /// 0..1
  final double confidence;
  final Set<ImageIssue> issues;
  final String? remarks;

  @override
  List<Object?> get props => [
    isOdometer,
    isImageClear,
    reading,
    unit,
    displayType,
    confidence,
    issues,
    remarks,
  ];
}
