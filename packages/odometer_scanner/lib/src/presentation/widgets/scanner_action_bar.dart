import 'package:flutter/material.dart';

class ScannerAction {
  const ScannerAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
}

/// Sticky bottom bar with one primary and an optional secondary action.
class ScannerActionBar extends StatelessWidget {
  const ScannerActionBar({super.key, required this.primary, this.secondary});

  final ScannerAction primary;
  final ScannerAction? secondary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final secondary = this.secondary;
    const size = Size.fromHeight(56);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.icon(
                onPressed: primary.onPressed,
                icon: Icon(primary.icon),
                label: Text(primary.label),
                style: FilledButton.styleFrom(minimumSize: size, shape: shape),
              ),
              if (secondary != null) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: secondary.onPressed,
                  icon: Icon(secondary.icon),
                  label: Text(secondary.label),
                  style: OutlinedButton.styleFrom(
                    minimumSize: size,
                    shape: shape,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
