import 'package:flutter_test/flutter_test.dart';
import 'package:odometer_scanner/odometer_scanner.dart';

import '../helpers/fixtures.dart';

void main() {
  const validator = OdometerReadingValidator();
  const context = ValidationContext(
    minConfidence: 0.75,
    maxReading: 999999,
    previousReading: 40000,
  );

  OdometerFailure? failureOf(OdometerAnalysis a) => validator
      .validate(a, context)
      .fold(onSuccess: (_) => null, onFailure: (f) => f);

  test('accepts a clear, confident, increasing reading', () {
    final result = validator.validate(analysis(), context);
    expect(result, isA<Success<int>>());
    expect((result as Success<int>).value, 45120);
  });

  test('parses readings with separators', () {
    expect(parseReading('45,120'), 45120);
    expect(parseReading('45 120'), 45120);
    expect(parseReading('45a120'), isNull);
    expect(parseReading(''), isNull);
    expect(parseReading(null), isNull);
  });

  final cases = <String, (OdometerAnalysis, Type)>{
    'edited / screen image': (
      analysis(issues: {ImageIssue.screenOrEdited}),
      SuspiciousImageFailure,
    ),
    'not an odometer': (analysis(isOdometer: false), NotAnOdometerFailure),
    'trip meter only': (
      analysis(issues: {ImageIssue.tripMeterOnly}),
      TripMeterOnlyFailure,
    ),
    'blurry': (analysis(issues: {ImageIssue.blurry}), BlurryImageFailure),
    'unclear without issue': (
      analysis(isImageClear: false),
      BlurryImageFailure,
    ),
    'glare': (analysis(issues: {ImageIssue.glare}), PoorLightingFailure),
    'unreadable digits': (analysis(reading: null), UnreadableReadingFailure),
    'obstructed digits': (
      analysis(issues: {ImageIssue.obstructed}),
      UnreadableReadingFailure,
    ),
    'low confidence': (analysis(confidence: 0.5), LowConfidenceFailure),
    'above max': (analysis(reading: '1000000'), ReadingOutOfRangeFailure),
    'below previous': (analysis(reading: '39999'), ReadingBelowPreviousFailure),
  };

  for (final MapEntry(key: name, value: (input, expected)) in cases.entries) {
    test('rejects $name', () {
      expect(failureOf(input).runtimeType, expected);
    });
  }

  test('a blurry non-odometer reports the more fundamental problem first', () {
    expect(
      failureOf(analysis(isOdometer: false, issues: {ImageIssue.blurry})),
      isA<NotAnOdometerFailure>(),
    );
  });
}
