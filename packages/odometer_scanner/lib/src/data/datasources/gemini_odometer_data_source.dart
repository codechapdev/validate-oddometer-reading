import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:odometer_scanner/src/data/datasources/gemini_exceptions.dart';
import 'package:odometer_scanner/src/data/datasources/odometer_prompt.dart';
import 'package:odometer_scanner/src/data/models/odometer_analysis_model.dart';
import 'package:odometer_scanner/src/domain/entities/captured_image.dart';

abstract interface class OdometerRemoteDataSource {
  Future<OdometerAnalysisModel> analyze(CapturedImage image);
}

/// Calls the Gemini `generateContent` REST endpoint with structured output.
/// Uses plain HTTP so the module has no dependency on a specific Gemini SDK.
class GeminiOdometerDataSource implements OdometerRemoteDataSource {
  GeminiOdometerDataSource({
    required String apiKey,
    required String model,
    required Duration timeout,
    http.Client? client,
  }) : _apiKey = apiKey,
       _model = model,
       _timeout = timeout,
       _client = client ?? http.Client();

  static const _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  final String _apiKey;
  final String _model;
  final Duration _timeout;
  final http.Client _client;

  @override
  Future<OdometerAnalysisModel> analyze(CapturedImage image) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/models/$_model:generateContent'),
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': _apiKey,
          },
          body: jsonEncode(_buildRequest(image)),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw GeminiHttpException(response.statusCode, _errorMessage(response));
    }
    return OdometerAnalysisModel.fromJson(_extractJsonPayload(response.body));
  }

  Map<String, Object> _buildRequest(CapturedImage image) => {
    'systemInstruction': {
      'parts': [
        {'text': OdometerPrompt.systemInstruction},
      ],
    },
    'contents': [
      {
        'role': 'user',
        'parts': [
          {
            'inlineData': {
              'mimeType': image.mimeType,
              'data': base64Encode(image.bytes),
            },
          },
          {'text': OdometerPrompt.userPrompt},
        ],
      },
    ],
    'generationConfig': {
      'temperature': 0,
      'responseMimeType': 'application/json',
      'responseSchema': OdometerPrompt.responseSchema,
    },
  };

  Map<String, dynamic> _extractJsonPayload(String body) {
    try {
      final root = jsonDecode(body) as Map<String, dynamic>;
      final blockReason =
          (root['promptFeedback'] as Map<String, dynamic>?)?['blockReason'];
      if (blockReason != null) {
        throw GeminiBlockedException('Request blocked: $blockReason');
      }

      final candidates = root['candidates'] as List<dynamic>? ?? const [];
      if (candidates.isEmpty) {
        throw const GeminiMalformedResponseException('No candidates returned');
      }
      final candidate = candidates.first as Map<String, dynamic>;
      final parts =
          (candidate['content'] as Map<String, dynamic>?)?['parts']
              as List<dynamic>? ??
          const [];
      final text = parts
          .whereType<Map<String, dynamic>>()
          .map((p) => p['text'])
          .whereType<String>()
          .join();
      if (text.isEmpty) {
        throw GeminiBlockedException(
          'Empty response (finishReason: ${candidate['finishReason']})',
        );
      }
      return jsonDecode(text) as Map<String, dynamic>;
    } on GeminiException {
      rethrow;
    } on Object catch (e) {
      throw GeminiMalformedResponseException(e.toString());
    }
  }

  String _errorMessage(http.Response response) {
    try {
      final root = jsonDecode(response.body) as Map<String, dynamic>;
      final error = root['error'] as Map<String, dynamic>?;
      return error?['message'] as String? ?? response.reasonPhrase ?? '';
    } on Object {
      return response.reasonPhrase ?? 'HTTP ${response.statusCode}';
    }
  }
}
