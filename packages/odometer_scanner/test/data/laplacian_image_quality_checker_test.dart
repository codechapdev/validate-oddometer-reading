import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:odometer_scanner/src/data/services/laplacian_image_quality_checker.dart';

void main() {
  img.Image checkerboard() {
    final image = img.Image(width: 400, height: 300);
    for (final p in image) {
      final on = ((p.x ~/ 8) + (p.y ~/ 8)).isEven;
      p
        ..r = on ? 255 : 0
        ..g = on ? 255 : 0
        ..b = on ? 255 : 0;
    }
    return image;
  }

  const checker = LaplacianImageQualityChecker(threshold: 80);

  test('sharp image passes', () async {
    final bytes = img.encodePng(checkerboard());
    expect(await checker.isSharp(bytes), isTrue);
  });

  test('heavily blurred image fails', () async {
    final bytes = img.encodePng(img.gaussianBlur(checkerboard(), radius: 12));
    expect(await checker.isSharp(bytes), isFalse);
  });

  test('a disabled threshold always passes', () async {
    const disabled = LaplacianImageQualityChecker(threshold: 0);
    final bytes = img.encodePng(img.Image(width: 50, height: 50));
    expect(await disabled.isSharp(bytes), isTrue);
  });
}
