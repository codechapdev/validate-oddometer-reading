import 'dart:typed_data';

import 'package:odometer_scanner/odometer_scanner.dart';

final testImage = CapturedImage(
  path: '/tmp/odo.jpg',
  bytes: Uint8List.fromList([1, 2, 3]),
  mimeType: 'image/jpeg',
);

OdometerAnalysis analysis({
  bool isOdometer = true,
  bool isImageClear = true,
  String? reading = '045120',
  double confidence = 0.95,
  Set<ImageIssue> issues = const {},
  DistanceUnit unit = DistanceUnit.kilometers,
}) => OdometerAnalysis(
  isOdometer: isOdometer,
  isImageClear: isImageClear,
  reading: reading,
  unit: unit,
  displayType: OdometerDisplayType.digital,
  confidence: confidence,
  issues: issues,
);
