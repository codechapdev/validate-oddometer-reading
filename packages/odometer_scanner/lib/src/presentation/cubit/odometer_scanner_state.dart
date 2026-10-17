part of 'odometer_scanner_cubit.dart';

sealed class OdometerScannerState extends Equatable {
  const OdometerScannerState();

  @override
  List<Object?> get props => [];
}

final class ScannerIdle extends OdometerScannerState {
  const ScannerIdle();
}

final class ScannerAnalyzing extends OdometerScannerState {
  const ScannerAnalyzing({required this.image, required this.step});

  final CapturedImage image;
  final AnalysisStep step;

  @override
  List<Object?> get props => [image, step];
}

final class ScannerSuccess extends OdometerScannerState {
  const ScannerSuccess({required this.image, required this.reading});

  final CapturedImage image;
  final OdometerReading reading;

  @override
  List<Object?> get props => [image, reading];
}

final class ScannerError extends OdometerScannerState {
  const ScannerError({required this.failure, this.image});

  final OdometerFailure failure;

  /// Image that failed, if any (absent when capture itself failed).
  final CapturedImage? image;

  @override
  List<Object?> get props => [failure, image];
}
