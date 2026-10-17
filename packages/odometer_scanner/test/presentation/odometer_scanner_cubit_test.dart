import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:odometer_scanner/odometer_scanner.dart';

import '../helpers/fixtures.dart';

class _MockCapture extends Mock implements ImageCaptureService {}

class _MockAnalyze extends Mock implements AnalyzeOdometerImage {}

void main() {
  late _MockCapture capture;
  late _MockAnalyze analyze;
  final reading = OdometerReading(
    value: 45120,
    unit: DistanceUnit.kilometers,
    confidence: 0.95,
    imagePath: testImage.path,
    capturedAt: DateTime(2026),
  );

  setUpAll(() {
    registerFallbackValue(testImage);
    registerFallbackValue(CaptureSource.camera);
  });

  setUp(() {
    capture = _MockCapture();
    analyze = _MockAnalyze();
  });

  OdometerScannerCubit build() => OdometerScannerCubit(
    captureService: capture,
    analyzeOdometerImage: analyze,
  );

  void stubAnalyze(Result<OdometerReading> result) {
    when(() => analyze(any(), onProgress: any(named: 'onProgress'))).thenAnswer(
      (invocation) async {
        final onProgress =
            invocation.namedArguments[#onProgress]
                as void Function(AnalysisStep)?;
        onProgress?.call(AnalysisStep.readingOdometer);
        return result;
      },
    );
  }

  blocTest<OdometerScannerCubit, OdometerScannerState>(
    'emits analyzing steps then success',
    setUp: () {
      when(
        () => capture.capture(any()),
      ).thenAnswer((_) async => Success(testImage));
      stubAnalyze(Success(reading));
    },
    build: build,
    act: (cubit) => cubit.capture(CaptureSource.camera),
    expect: () => [
      ScannerAnalyzing(image: testImage, step: AnalysisStep.checkingQuality),
      ScannerAnalyzing(image: testImage, step: AnalysisStep.readingOdometer),
      ScannerSuccess(image: testImage, reading: reading),
    ],
  );

  blocTest<OdometerScannerCubit, OdometerScannerState>(
    'emits error with image when validation fails',
    setUp: () {
      when(
        () => capture.capture(any()),
      ).thenAnswer((_) async => Success(testImage));
      stubAnalyze(const Failure(BlurryImageFailure()));
    },
    build: build,
    act: (cubit) => cubit.capture(CaptureSource.gallery),
    skip: 2,
    expect: () => [
      ScannerError(failure: const BlurryImageFailure(), image: testImage),
    ],
  );

  blocTest<OdometerScannerCubit, OdometerScannerState>(
    'stays idle when user cancels capture',
    setUp: () => when(
      () => capture.capture(any()),
    ).thenAnswer((_) async => const Success(null)),
    build: build,
    act: (cubit) => cubit.capture(CaptureSource.camera),
    expect: () => <OdometerScannerState>[],
  );

  blocTest<OdometerScannerCubit, OdometerScannerState>(
    'retry re-analyses the same image',
    setUp: () => stubAnalyze(Success(reading)),
    build: build,
    seed: () => ScannerError(failure: const NetworkFailure(), image: testImage),
    act: (cubit) => cubit.retry(),
    skip: 2,
    expect: () => [ScannerSuccess(image: testImage, reading: reading)],
  );

  blocTest<OdometerScannerCubit, OdometerScannerState>(
    'reset returns to idle',
    build: build,
    seed: () => ScannerSuccess(image: testImage, reading: reading),
    act: (cubit) => cubit.reset(),
    expect: () => [const ScannerIdle()],
  );
}
