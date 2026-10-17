import 'package:equatable/equatable.dart';

/// All tunables for the module. Hosts create one instance per scan session
/// so contextual rules (e.g. the vehicle's previous reading) can differ.
class OdometerScannerConfig extends Equatable {
  const OdometerScannerConfig({
    required this.geminiApiKey,
    this.geminiModel = 'gemini-flash-latest',
    this.previousReading,
    this.maxReading = 9999999,
    this.minConfidence = 0.75,
    this.blurThreshold = 80,
    this.requestTimeout = const Duration(seconds: 30),
    this.maxImageWidth = 1600,
    this.imageQuality = 85,
  }) : assert(minConfidence >= 0 && minConfidence <= 1);

  /// API key for Google AI Studio (Gemini API). Never hard-code in source;
  /// inject via `--dart-define` or fetch from your backend.
  final String geminiApiKey;

  /// Gemini model id. Defaults to the rolling Flash alias.
  final String geminiModel;

  /// Last known reading for the vehicle; new readings must be >= this value.
  final int? previousReading;

  /// Upper sanity bound for a reading.
  final int maxReading;

  /// Minimum AI confidence (0..1) required to accept a reading.
  final double minConfidence;

  /// Laplacian-variance threshold for the on-device blur pre-check.
  /// Lower = more tolerant. Set to 0 to disable the local check.
  final double blurThreshold;

  final Duration requestTimeout;

  /// Images are downscaled at capture time to keep uploads small.
  final double maxImageWidth;
  final int imageQuality;

  @override
  List<Object?> get props => [
    geminiApiKey,
    geminiModel,
    previousReading,
    maxReading,
    minConfidence,
    blurThreshold,
    requestTimeout,
    maxImageWidth,
    imageQuality,
  ];
}
