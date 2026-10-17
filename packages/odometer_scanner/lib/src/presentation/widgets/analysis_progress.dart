import 'package:flutter/material.dart';
import 'package:odometer_scanner/src/domain/usecases/analyze_odometer_image.dart';

/// Vertical stepper reflecting the current analysis step.
class AnalysisProgress extends StatelessWidget {
  const AnalysisProgress({super.key, required this.current});

  final AnalysisStep current;

  static String _label(AnalysisStep step) => switch (step) {
    AnalysisStep.checkingQuality => 'Checking photo sharpness',
    AnalysisStep.readingOdometer => 'Reading odometer with AI',
    AnalysisStep.validating => 'Validating reading',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            for (final step in AnalysisStep.values)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox.square(
                      dimension: 24,
                      child: _StepIcon(
                        done: step.index < current.index,
                        active: step == current,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        style: theme.textTheme.bodyLarge!.copyWith(
                          color: step.index <= current.index
                              ? scheme.onSurface
                              : scheme.onSurfaceVariant.withValues(alpha: 0.6),
                          fontWeight: step == current
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        child: Text(_label(step)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StepIcon extends StatelessWidget {
  const _StepIcon({required this.done, required this.active});

  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: done
          ? Icon(
              Icons.check_circle_rounded,
              key: const ValueKey('done'),
              color: scheme.primary,
            )
          : active
          ? Padding(
              key: const ValueKey('active'),
              padding: const EdgeInsets.all(3),
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: scheme.primary,
              ),
            )
          : Icon(
              Icons.radio_button_unchecked_rounded,
              key: const ValueKey('pending'),
              color: scheme.outlineVariant,
            ),
    );
  }
}
