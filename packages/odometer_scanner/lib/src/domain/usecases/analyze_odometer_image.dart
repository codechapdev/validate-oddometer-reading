import 'package:odometer_scanner/src/core/failures.dart';
import 'package:odometer_scanner/src/core/result.dart';
import 'package:odometer_scanner/src/domain/entities/captured_image.dart';
import 'package:odometer_scanner/src/domain/entities/odometer_reading.dart';
import 'package:odometer_scanner/src/domain/repositories/odometer_repository.dart';
import 'package:odometer_scanner/src/domain/services/image_quality_checker.dart';
import 'package:odometer_scanner/src/domain/validation/odometer_reading_validator.dart';
import 'package:odometer_scanner/src/domain/validation/reading_validation_rule.dart';

enum AnalysisStep { checkingQuality, readingOdometer, validating }

/// Orchestrates: local blur check -> AI extraction -> business validation.
class AnalyzeOdometerImage {
  const AnalyzeOdometerImage({
    required OdometerRepository repository,
    required ImageQualityChecker qualityChecker,
    required OdometerReadingValidator validator,
    required ValidationContext validationContext,
    DateTime Function() clock = DateTime.now,
  }) : _repository = repository,
       _qualityChecker = qualityChecker,
       _validator = validator,
       _context = validationContext,
       _clock = clock;

  final OdometerRepository _repository;
  final ImageQualityChecker _qualityChecker;
  final OdometerReadingValidator _validator;
  final ValidationContext _context;
  final DateTime Function() _clock;

  Future<Result<OdometerReading>> call(
    CapturedImage image, {
    void Function(AnalysisStep step)? onProgress,
  }) async {
    onProgress?.call(AnalysisStep.checkingQuality);
    if (!await _qualityChecker.isSharp(image.bytes)) {
      return const Failure(BlurryImageFailure());
    }

    onProgress?.call(AnalysisStep.readingOdometer);
    final analysisResult = await _repository.analyze(image);

    return switch (analysisResult) {
      Failure(:final failure) => Failure(failure),
      Success(value: final analysis) => () {
        onProgress?.call(AnalysisStep.validating);
        return switch (_validator.validate(analysis, _context)) {
          Failure(:final failure) => Failure<OdometerReading>(failure),
          Success(:final value) => Success(
            OdometerReading(
              value: value,
              unit: analysis.unit,
              confidence: analysis.confidence,
              imagePath: image.path,
              capturedAt: _clock(),
            ),
          ),
        };
      }(),
    };
  }
}
