import 'dart:typed_data';

import 'package:flutter/material.dart';

enum PreviewStatus { scanning, verified, rejected }

/// Rounded photo preview with viewfinder corners, an animated scan line
/// while analysing and a status badge once finished.
class ImagePreview extends StatelessWidget {
  const ImagePreview({super.key, required this.bytes, required this.status});

  final Uint8List bytes;
  final PreviewStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = switch (status) {
      PreviewStatus.scanning => scheme.primary,
      PreviewStatus.verified => const Color(0xFF1E9E5A),
      PreviewStatus.rejected => scheme.error,
    };

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accent, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(21),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true),
              if (status == PreviewStatus.scanning) ...[
                ColoredBox(color: Colors.black.withValues(alpha: 0.25)),
                CustomPaint(painter: _ViewfinderPainter(accent)),
                _ScanLine(color: accent),
              ],
              if (status != PreviewStatus.scanning)
                Positioned(
                  top: 12,
                  right: 12,
                  child: _StatusBadge(status: status, color: accent),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.color});

  final PreviewStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final verified = status == PreviewStatus.verified;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              verified ? Icons.verified_rounded : Icons.error_rounded,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              verified ? 'Verified' : 'Rejected',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanLine extends StatefulWidget {
  const _ScanLine({required this.color});

  final Color color;

  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      builder: (context, _) => Align(
        alignment: Alignment(0, _controller.value * 1.6 - 0.8),
        child: Container(
          height: 3,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.8),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  const _ViewfinderPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const inset = 20.0;
    const len = 28.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final l = inset, t = inset;
    final r = size.width - inset, b = size.height - inset;
    final path = Path()
      ..moveTo(l, t + len)
      ..lineTo(l, t)
      ..lineTo(l + len, t)
      ..moveTo(r - len, t)
      ..lineTo(r, t)
      ..lineTo(r, t + len)
      ..moveTo(r, b - len)
      ..lineTo(r, b)
      ..lineTo(r - len, b)
      ..moveTo(l + len, b)
      ..lineTo(l, b)
      ..lineTo(l, b - len);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ViewfinderPainter oldDelegate) =>
      oldDelegate.color != color;
}
