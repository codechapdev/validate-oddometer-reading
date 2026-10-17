import 'package:odometer_scanner/src/core/result.dart';
import 'package:odometer_scanner/src/domain/entities/captured_image.dart';

abstract interface class ImageCaptureService {
  /// Returns `Success(null)` when the user cancels.
  Future<Result<CapturedImage?>> capture(CaptureSource source);
}
