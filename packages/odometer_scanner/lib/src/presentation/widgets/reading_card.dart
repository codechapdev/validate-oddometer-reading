import 'package:flutter/material.dart';
import 'package:odometer_scanner/src/domain/entities/odometer_analysis.dart';
import 'package:odometer_scanner/src/domain/entities/odometer_reading.dart';
import 'package:odometer_scanner/src/presentation/widgets/number_format.dart';

/// Shows the verified reading as a stylised mechanical odometer.
class ReadingCard extends StatelessWidget {
  const ReadingCard({super.key, required this.reading, this.previousReading});

  final OdometerReading reading;
  final int? previousReading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final previous = previousReading;

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'ODOMETER READING',
              style: theme.textTheme.labelMedium?.copyWith(
                letterSpacing: 1.6,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            Semantics(
              label: 'Odometer reading ${reading.value} ${reading.unit.name}',
              excludeSemantics: true,
              child: _DigitStrip(value: reading.value, unit: reading.unit),
            ),
            const SizedBox(height: 20),
            _ConfidenceMeter(confidence: reading.confidence),
            if (previous != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '+${formatThousands(reading.value - previous)} '
                      'since last reading',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DigitStrip extends StatelessWidget {
  const _DigitStrip({required this.value, required this.unit});

  final int value;
  final DistanceUnit unit;

  @override
  Widget build(BuildContext context) {
    final digits = value.toString().padLeft(6, '0').split('');
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF0E1116),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < digits.length; i++)
              _DigitTile(digit: digits[i], index: i),
            if (unit != DistanceUnit.unknown)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  unit.symbol.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFB7C0CC),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DigitTile extends StatelessWidget {
  const _DigitTile({required this.digit, required this.index});

  final String digit;
  final int index;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + index * 70),
      curve: Curves.easeOutBack,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0, 1),
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 16),
          child: child,
        ),
      ),
      child: Container(
        width: 40,
        height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A303A), Color(0xFF1A1F27), Color(0xFF2A303A)],
          ),
        ),
        child: Text(
          digit,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

class _ConfidenceMeter extends StatelessWidget {
  const _ConfidenceMeter({required this.confidence});

  final double confidence;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final percent = (confidence * 100).round();
    final color = confidence >= 0.9
        ? const Color(0xFF1E9E5A)
        : confidence >= 0.75
        ? const Color(0xFFE0A100)
        : scheme.error;

    return Column(
      children: [
        Row(
          children: [
            Text('AI confidence', style: theme.textTheme.bodyMedium),
            const Spacer(),
            Text(
              '$percent%',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: confidence),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => LinearProgressIndicator(
            value: value,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
            color: color,
            backgroundColor: color.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }
}
