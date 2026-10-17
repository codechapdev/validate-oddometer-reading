import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:odometer_scanner/src/core/failures.dart';
import 'package:odometer_scanner/src/core/result.dart';
import 'package:odometer_scanner/src/domain/entities/captured_image.dart';
import 'package:odometer_scanner/src/domain/services/image_capture_service.dart';

class ImagePickerCaptureService implements ImageCaptureService {
  ImagePickerCaptureService({
    required double maxWidth,
    required int imageQuality,
    ImagePicker? picker,
  }) : _maxWidth = maxWidth,
       _imageQuality = imageQuality,
       _picker = picker ?? ImagePicker();

  final double _maxWidth;
  final int _imageQuality;
  final ImagePicker _picker;

  @override
  Future<Result<CapturedImage?>> capture(CaptureSource source) async {
    try {
      final file = await _picker.pickImage(
        source: switch (source) {
          CaptureSource.camera => ImageSource.camera,
          CaptureSource.gallery => ImageSource.gallery,
        },
        maxWidth: _maxWidth,
        imageQuality: _imageQuality,
        preferredCameraDevice: CameraDevice.rear,
        requestFullMetadata: false,
      );
      if (file == null) return const Success(null);

      return Success(
        CapturedImage(
          path: file.path,
          bytes: await file.readAsBytes(),
          mimeType: file.mimeType ?? _mimeFromPath(file.path),
        ),
      );
    } on PlatformException catch (e) {
      return Failure(ImagePickFailure(detail: e.message));
    }
  }

  static String _mimeFromPath(String path) {
    final ext = path.split('.').last.toLowerCase();
    return switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      'heif' => 'image/heif',
      _ => 'image/jpeg',
    };
  }
}
