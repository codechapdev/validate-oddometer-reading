import 'package:flutter/material.dart';
import 'package:odometer_scanner/src/presentation/widgets/number_format.dart';

/// Empty-state hero that explains how to take a good odometer photo.
class CaptureGuide extends StatelessWidget {
  const CaptureGuide({super.key, this.previousReading});

  final int? previousReading;

  static const _tips = [
    (
      Icons.crop_free_rounded,
      'Fill the frame',
      'Keep the odometer large and centred',
    ),
    (
      Icons.wb_sunny_outlined,
      'Avoid glare',
      'Tilt slightly to remove reflections',
    ),
    (Icons.pan_tool_alt_outlined, 'Hold steady', 'Tap to focus, then capture'),
    (Icons.speed_rounded, 'Show ODO', 'Switch the display from TRIP to ODO'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [scheme.primary, scheme.tertiary],
              ),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.35),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(Icons.speed_rounded, size: 60, color: scheme.onPrimary),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Capture your odometer',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "We'll read and verify the total distance automatically.",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        if (previousReading case final previous?) ...[
          const SizedBox(height: 16),
          Center(
            child: Chip(
              avatar: Icon(
                Icons.history_rounded,
                size: 18,
                color: scheme.primary,
              ),
              label: Text('Last recorded: ${formatThousands(previous)}'),
              side: BorderSide.none,
              backgroundColor: scheme.primaryContainer.withValues(alpha: 0.5),
            ),
          ),
        ],
        const SizedBox(height: 28),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.25,
          children: [
            for (final (icon, title, subtitle) in _tips)
              _TipTile(icon: icon, title: title, subtitle: subtitle),
          ],
        ),
      ],
    );
  }
}

class _TipTile extends StatelessWidget {
  const _TipTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
