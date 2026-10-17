import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:odometer_scanner/odometer_scanner.dart';

import '../helpers/fixtures.dart';

class _MockRepository extends Mock implements OdometerRepository {}

class _MockQualityChecker extends Mock implements ImageQualityChecker {}

void main() {
  late _MockRepository repository;
  late _MockQualityChecker checker;
  late AnalyzeOdometerImage useCase;
  final now = DateTime(2026, 10, 14);

  setUpAll(() {
    registerFallbackValue(testImage);
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    repository = _MockRepository();
    checker = _MockQualityChecker();
    useCase = AnalyzeOdometerImage(
      repository: repository,
      qualityChecker: checker,
      validator: const OdometerReadingValidator(),
      validationContext: const ValidationContext(
        minConfidence: 0.75,
        maxReading: 9999999,
      ),
      clock: () => now,
    );
  });

  test('short-circuits on a locally blurry image without calling AI', () async {
    when(() => checker.isSharp(any())).thenAnswer((_) async => false);

    final result = await useCase(testImage);

    expect((result as Failure).failure, isA<BlurryImageFailure>());
    verifyNever(() => repository.analyze(any()));
  });

  test('returns a validated reading and reports every step', () async {
    when(() => checker.isSharp(any())).thenAnswer((_) async => true);
    when(
      () => repository.analyze(any()),
    ).thenAnswer((_) async => Success(analysis()));
    final steps = <AnalysisStep>[];

    final result = await useCase(testImage, onProgress: steps.add);

    expect(
      (result as Success<OdometerReading>).value,
      OdometerReading(
        value: 45120,
        unit: DistanceUnit.kilometers,
        confidence: 0.95,
        imagePath: testImage.path,
        capturedAt: now,
      ),
    );
    expect(steps, AnalysisStep.values);
  });

  test('propagates repository failures', () async {
    when(() => checker.isSharp(any())).thenAnswer((_) async => true);
    when(
      () => repository.analyze(any()),
    ).thenAnswer((_) async => const Failure(NetworkFailure()));

    final result = await useCase(testImage);

    expect((result as Failure).failure, isA<NetworkFailure>());
  });
}
