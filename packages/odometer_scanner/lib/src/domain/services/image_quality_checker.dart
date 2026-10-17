import 'dart:typed_data';

/// Fast, on-device sharpness check run before spending an AI call.
abstract interface class ImageQualityChecker {
  Future<bool> isSharp(Uint8List bytes);
}
