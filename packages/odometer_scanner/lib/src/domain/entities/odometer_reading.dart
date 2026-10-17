import 'package:equatable/equatable.dart';
import 'package:odometer_scanner/src/domain/entities/odometer_analysis.dart';

/// A validated odometer reading. This is the public output of the module.
class OdometerReading extends Equatable {
  const OdometerReading({
    required this.value,
    required this.unit,
    required this.confidence,
    required this.imagePath,
    required this.capturedAt,
  });

  final int value;
  final DistanceUnit unit;
  final double confidence;

  /// Local path of the photo used as evidence.
  final String imagePath;
  final DateTime capturedAt;

  @override
  List<Object?> get props => [value, unit, confidence, imagePath, capturedAt];

  @override
  String toString() =>
      'OdometerReading($value ${unit.symbol}, '
      'confidence: ${confidence.toStringAsFixed(2)})';
}
