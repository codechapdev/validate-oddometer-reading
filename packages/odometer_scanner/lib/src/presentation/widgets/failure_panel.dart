import 'package:flutter/material.dart';
import 'package:odometer_scanner/src/core/failures.dart';

class FailurePanel extends StatelessWidget {
  const FailurePanel({super.key, required this.failure});

  final OdometerFailure failure;

  IconData get _icon => switch (failure) {
    BlurryImageFailure() => Icons.blur_on_rounded,
    PoorLightingFailure() => Icons.wb_sunny_rounded,
    NotAnOdometerFailure() => Icons.image_not_supported_rounded,
    TripMeterOnlyFailure() => Icons.alt_route_rounded,
    UnreadableReadingFailure() => Icons.visibility_off_rounded,
    LowConfidenceFailure() => Icons.help_outline_rounded,
    ReadingBelowPreviousFailure() => Icons.trending_down_rounded,
    ReadingOutOfRangeFailure() => Icons.report_rounded,
    SuspiciousImageFailure() => Icons.gpp_maybe_rounded,
    NetworkFailure() => Icons.wifi_off_rounded,
    AiServiceFailure() => Icons.cloud_off_rounded,
    ImagePickFailure() => Icons.no_photography_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: scheme.errorContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: scheme.error,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_icon, color: scheme.onError, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    failure.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              failure.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onErrorContainer,
              ),
            ),
            if (failure.hints.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'How to fix',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.onErrorContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              for (final hint in failure.hints)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: scheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          hint,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
