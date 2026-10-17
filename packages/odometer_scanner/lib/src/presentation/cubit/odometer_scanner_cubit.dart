import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odometer_scanner/src/core/failures.dart';
import 'package:odometer_scanner/src/core/result.dart';
import 'package:odometer_scanner/src/domain/entities/captured_image.dart';
import 'package:odometer_scanner/src/domain/entities/odometer_reading.dart';
import 'package:odometer_scanner/src/domain/services/image_capture_service.dart';
import 'package:odometer_scanner/src/domain/usecases/analyze_odometer_image.dart';

part 'odometer_scanner_state.dart';

class OdometerScannerCubit extends Cubit<OdometerScannerState> {
  OdometerScannerCubit({
    required ImageCaptureService captureService,
    required AnalyzeOdometerImage analyzeOdometerImage,
  }) : _captureService = captureService,
       _analyze = analyzeOdometerImage,
       super(const ScannerIdle());

  final ImageCaptureService _captureService;
  final AnalyzeOdometerImage _analyze;

  bool get _isBusy => state is ScannerAnalyzing;

  Future<void> capture(CaptureSource source) async {
    if (_isBusy) return;

    final result = await _captureService.capture(source);
    if (isClosed) return;

    switch (result) {
      case Failure(:final failure):
        emit(ScannerError(failure: failure));
      case Success(value: null):
        break; // User cancelled; keep current state.
      case Success(value: final CapturedImage image):
        await _run(image);
    }
  }

  /// Re-runs analysis on the current image (e.g. after a network error).
  Future<void> retry() async {
    final image = switch (state) {
      ScannerError(:final image) => image,
      _ => null,
    };
    if (image != null && !_isBusy) await _run(image);
  }

  void reset() => emit(const ScannerIdle());

  Future<void> _run(CapturedImage image) async {
    emit(ScannerAnalyzing(image: image, step: AnalysisStep.checkingQuality));

    final result = await _analyze(
      image,
      onProgress: (step) {
        if (!isClosed) emit(ScannerAnalyzing(image: image, step: step));
      },
    );
    if (isClosed) return;

    emit(
      result.fold(
        onSuccess: (reading) => ScannerSuccess(image: image, reading: reading),
        onFailure: (failure) => ScannerError(failure: failure, image: image),
      ),
    );
  }
}
