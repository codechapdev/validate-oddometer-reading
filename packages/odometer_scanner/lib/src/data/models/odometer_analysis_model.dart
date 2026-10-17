import 'package:odometer_scanner/src/domain/entities/odometer_analysis.dart';

/// DTO for the Gemini structured response. Parsing is defensive because LLM
/// output can deviate from the requested schema.
class OdometerAnalysisModel {
  const OdometerAnalysisModel({
    required this.isOdometer,
    required this.isImageClear,
    required this.reading,
    required this.unit,
    required this.displayType,
    required this.confidence,
    required this.issues,
    required this.remarks,
  });

  factory OdometerAnalysisModel.fromJson(Map<String, dynamic> json) {
    final rawReading = json['reading'];
    final rawRemarks = json['remarks'];
    return OdometerAnalysisModel(
      isOdometer: json['isOdometer'] == true,
      isImageClear: json['isImageClear'] == true,
      reading: rawReading is String && rawReading.trim().isNotEmpty
          ? rawReading.trim()
          : (rawReading is num ? rawReading.toInt().toString() : null),
      unit: json['unit'] as String? ?? 'unknown',
      displayType: json['displayType'] as String? ?? 'unknown',
      confidence: ((json['confidence'] as num?)?.toDouble() ?? 0).clamp(0, 1),
      issues: (json['issues'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      remarks: rawRemarks is String && rawRemarks.isNotEmpty
          ? rawRemarks
          : null,
    );
  }

  final bool isOdometer;
  final bool isImageClear;
  final String? reading;
  final String unit;
  final String displayType;
  final double confidence;
  final List<String> issues;
  final String? remarks;

  static const _issueMap = {
    'blurry': ImageIssue.blurry,
    'glare': ImageIssue.glare,
    'too_dark': ImageIssue.tooDark,
    'partially_visible': ImageIssue.partiallyVisible,
    'obstructed': ImageIssue.obstructed,
    'not_an_odometer': ImageIssue.notAnOdometer,
    'trip_meter_only': ImageIssue.tripMeterOnly,
    'screen_or_edited': ImageIssue.screenOrEdited,
  };

  OdometerAnalysis toEntity() => OdometerAnalysis(
    isOdometer: isOdometer,
    isImageClear: isImageClear,
    reading: reading,
    unit: switch (unit) {
      'km' => DistanceUnit.kilometers,
      'mi' => DistanceUnit.miles,
      _ => DistanceUnit.unknown,
    },
    displayType: switch (displayType) {
      'digital' => OdometerDisplayType.digital,
      'analog' => OdometerDisplayType.analog,
      _ => OdometerDisplayType.unknown,
    },
    confidence: confidence,
    issues: issues.map((i) => _issueMap[i]).nonNulls.toSet(),
    remarks: remarks,
  );
}
