import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:odometer_scanner/src/core/failures.dart';
import 'package:odometer_scanner/src/core/result.dart';
import 'package:odometer_scanner/src/data/datasources/gemini_exceptions.dart';
import 'package:odometer_scanner/src/data/datasources/gemini_odometer_data_source.dart';
import 'package:odometer_scanner/src/domain/entities/captured_image.dart';
import 'package:odometer_scanner/src/domain/entities/odometer_analysis.dart';
import 'package:odometer_scanner/src/domain/repositories/odometer_repository.dart';

class GeminiOdometerRepository implements OdometerRepository {
  const GeminiOdometerRepository(this._remote);

  final OdometerRemoteDataSource _remote;

  @override
  Future<Result<OdometerAnalysis>> analyze(CapturedImage image) async {
    try {
      final model = await _remote.analyze(image);
      return Success(model.toEntity());
    } on SocketException {
      return const Failure(NetworkFailure());
    } on http.ClientException {
      return const Failure(NetworkFailure());
    } on TimeoutException {
      return const Failure(
        AiServiceFailure(detail: 'The request timed out. Please try again.'),
      );
    } on GeminiHttpException catch (e) {
      return Failure(AiServiceFailure(detail: _describeHttp(e)));
    } on GeminiBlockedException {
      return const Failure(UnreadableReadingFailure());
    } on GeminiMalformedResponseException {
      return const Failure(AiServiceFailure());
    }
  }

  String _describeHttp(GeminiHttpException e) => switch (e.statusCode) {
    400 when e.message.toLowerCase().contains('api key') =>
      'The Gemini API key is invalid.',
    401 || 403 => 'The Gemini API key is not authorised.',
    404 => 'The configured Gemini model was not found.',
    413 => 'The photo is too large. Please retake it.',
    402 =>
      'The Gemini API requires payment for this request. Check billing and usage limits for the Google Cloud project linked to this API key.',
    429 => 'Too many requests. Please wait a moment and try again.',
    >= 500 => 'The verification service is temporarily unavailable.',
    _ => 'Verification failed (${e.statusCode}).',
  };
}
