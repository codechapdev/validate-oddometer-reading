import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:odometer_scanner/src/domain/services/image_quality_checker.dart';

/// Detects blur using the variance of the Laplacian.
///
/// The image is split into a grid and the sharpest tile is used, because an
/// odometer often fills only part of the frame while the rest of the
/// dashboard is naturally smooth. Global blur (shake / defocus) lowers every
/// tile, so the max-tile score is a robust "is anything in focus" signal.
class LaplacianImageQualityChecker implements ImageQualityChecker {
  const LaplacianImageQualityChecker({required this.threshold});

  final double threshold;

  static const _analysisWidth = 512;
  static const _grid = 4;

  @override
  Future<bool> isSharp(Uint8List bytes) async {
    if (threshold <= 0) return true;
    final score = await Isolate.run(() => sharpnessScore(bytes));
    // Undecodable formats (e.g. HEIC) are deferred to the AI check.
    return score == null || score >= threshold;
  }

  /// Returns the max per-tile Laplacian variance, or null if undecodable.
  static double? sharpnessScore(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    final resized = decoded.width > _analysisWidth
        ? img.copyResize(decoded, width: _analysisWidth)
        : decoded;
    final gray = img.grayscale(resized);
    final w = gray.width;
    final h = gray.height;
    if (w < 3 || h < 3) return null;

    final lum = Float64List(w * h);
    for (final p in gray) {
      lum[p.y * w + p.x] = p.r.toDouble();
    }

    final tileW = math.max(1, (w - 2) ~/ _grid);
    final tileH = math.max(1, (h - 2) ~/ _grid);
    var best = 0.0;

    for (var ty = 0; ty < _grid; ty++) {
      for (var tx = 0; tx < _grid; tx++) {
        var sum = 0.0;
        var sumSq = 0.0;
        var n = 0;
        final yEnd = math.min(h - 1, 1 + (ty + 1) * tileH);
        final xEnd = math.min(w - 1, 1 + (tx + 1) * tileW);
        for (var y = 1 + ty * tileH; y < yEnd; y++) {
          for (var x = 1 + tx * tileW; x < xEnd; x++) {
            final i = y * w + x;
            final lap =
                lum[i - w] + lum[i + w] + lum[i - 1] + lum[i + 1] - 4 * lum[i];
            sum += lap;
            sumSq += lap * lap;
            n++;
          }
        }
        if (n == 0) continue;
        final mean = sum / n;
        best = math.max(best, sumSq / n - mean * mean);
      }
    }
    return best;
  }
}
