import 'package:http/http.dart' as http;
import 'package:odometer_scanner/src/core/odometer_scanner_config.dart';
import 'package:odometer_scanner/src/data/datasources/gemini_odometer_data_source.dart';
import 'package:odometer_scanner/src/data/repositories/gemini_odometer_repository.dart';
import 'package:odometer_scanner/src/data/services/image_picker_capture_service.dart';
import 'package:odometer_scanner/src/data/services/laplacian_image_quality_checker.dart';
import 'package:odometer_scanner/src/domain/services/image_capture_service.dart';
import 'package:odometer_scanner/src/domain/usecases/analyze_odometer_image.dart';
import 'package:odometer_scanner/src/domain/validation/odometer_reading_validator.dart';
import 'package:odometer_scanner/src/domain/validation/reading_validation_rule.dart';
import 'package:odometer_scanner/src/presentation/cubit/odometer_scanner_cubit.dart';

/// Composition root of the module. Hosts may supply their own
/// implementations (e.g. a custom camera or a backend proxy for Gemini)
/// without touching the rest of the module (Dependency Inversion).
class OdometerScannerDependencies {
  const OdometerScannerDependencies({
    required this.captureService,
    required this.analyzeOdometerImage,
  });

  factory OdometerScannerDependencies.fromConfig(
    OdometerScannerConfig config, {
    http.Client? httpClient,
    ImageCaptureService? captureService,
  }) => OdometerScannerDependencies(
    captureService:
        captureService ??
        ImagePickerCaptureService(
          maxWidth: config.maxImageWidth,
          imageQuality: config.imageQuality,
        ),
    analyzeOdometerImage: createAnalyzer(config, httpClient: httpClient),
  );

  final ImageCaptureService captureService;
  final AnalyzeOdometerImage analyzeOdometerImage;

  /// Headless analyzer for use without the bundled UI.
  static AnalyzeOdometerImage createAnalyzer(
    OdometerScannerConfig config, {
    http.Client? httpClient,
  }) => AnalyzeOdometerImage(
    repository: GeminiOdometerRepository(
      GeminiOdometerDataSource(
        apiKey: config.geminiApiKey,
        model: config.geminiModel,
        timeout: config.requestTimeout,
        client: httpClient,
      ),
    ),
    qualityChecker: LaplacianImageQualityChecker(
      threshold: config.blurThreshold,
    ),
    validator: const OdometerReadingValidator(),
    validationContext: ValidationContext(
      minConfidence: config.minConfidence,
      maxReading: config.maxReading,
      previousReading: config.previousReading,
    ),
  );

  OdometerScannerCubit createCubit() => OdometerScannerCubit(
    captureService: captureService,
    analyzeOdometerImage: analyzeOdometerImage,
  );
}
