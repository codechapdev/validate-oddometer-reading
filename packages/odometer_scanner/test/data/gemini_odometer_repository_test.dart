import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:odometer_scanner/odometer_scanner.dart';
import 'package:odometer_scanner/src/data/datasources/gemini_odometer_data_source.dart';
import 'package:odometer_scanner/src/data/repositories/gemini_odometer_repository.dart';

import '../helpers/fixtures.dart';

String _geminiBody(Map<String, Object?> payload) => jsonEncode({
  'candidates': [
    {
      'content': {
        'parts': [
          {'text': jsonEncode(payload)},
        ],
      },
      'finishReason': 'STOP',
    },
  ],
});

GeminiOdometerRepository _repo(MockClientHandler handler) =>
    GeminiOdometerRepository(
      GeminiOdometerDataSource(
        apiKey: 'test-key',
        model: 'test-model',
        timeout: const Duration(seconds: 5),
        client: MockClient(handler),
      ),
    );

void main() {
  test('sends a structured-output request and maps the response', () async {
    late http.Request captured;
    final repo = _repo((request) async {
      captured = request;
      return http.Response(
        _geminiBody({
          'isOdometer': true,
          'isImageClear': true,
          'reading': '123456',
          'unit': 'mi',
          'displayType': 'analog',
          'confidence': 0.92,
          'issues': ['glare', 'something_new'],
          'remarks': null,
        }),
        200,
      );
    });

    final result = await repo.analyze(testImage);

    expect(captured.url.path, endsWith('/models/test-model:generateContent'));
    expect(captured.headers['x-goog-api-key'], 'test-key');
    final body = jsonDecode(captured.body) as Map<String, dynamic>;
    final config = body['generationConfig'] as Map<String, dynamic>;
    expect(config['responseMimeType'], 'application/json');

    final value = (result as Success<OdometerAnalysis>).value;
    expect(value.reading, '123456');
    expect(value.unit, DistanceUnit.miles);
    expect(value.displayType, OdometerDisplayType.analog);
    expect(value.issues, {ImageIssue.glare}); // unknown issues are ignored
  });

  test('maps HTTP 429 to a service failure', () async {
    final repo = _repo((_) async => http.Response('{"error":{}}', 429));
    final result = await repo.analyze(testImage);
    expect((result as Failure).failure, isA<AiServiceFailure>());
  });

  test('explains HTTP 402 as a billing or usage-limit issue', () async {
    final repo = _repo((_) async => http.Response('{"error":{}}', 402));
    final result = await repo.analyze(testImage);
    final failure = (result as Failure).failure as AiServiceFailure;
    expect(failure.message, contains('requires payment'));
    expect(failure.message, contains('billing and usage limits'));
  });

  test('maps transport errors to a network failure', () async {
    final repo = _repo((_) async => throw http.ClientException('offline'));
    final result = await repo.analyze(testImage);
    expect((result as Failure).failure, isA<NetworkFailure>());
  });

  test('maps a safety-blocked prompt to an unreadable failure', () async {
    final repo = _repo(
      (_) async => http.Response(
        jsonEncode({
          'promptFeedback': {'blockReason': 'SAFETY'},
        }),
        200,
      ),
    );
    final result = await repo.analyze(testImage);
    expect((result as Failure).failure, isA<UnreadableReadingFailure>());
  });

  test('maps non-JSON model output to a service failure', () async {
    final repo = _repo(
      (_) async => http.Response(
        jsonEncode({
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'not json'},
                ],
              },
            },
          ],
        }),
        200,
      ),
    );
    final result = await repo.analyze(testImage);
    expect((result as Failure).failure, isA<AiServiceFailure>());
  });
}
