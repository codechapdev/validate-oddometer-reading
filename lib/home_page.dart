import 'package:flutter/material.dart';
import 'package:odometer_scanner/odometer_scanner.dart';

/// Example host screen: a vehicle's reading history. Demonstrates that the
/// scanner is consumed through a single call and returns a typed result.
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.apiKey, required this.model});

  final String apiKey;
  final String model;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<OdometerReading> _history = [];

  int? get _lastReading => _history.isEmpty ? null : _history.first.value;

  Future<void> _scan() async {
    final reading = await OdometerScanner.scan(
      context,
      config: OdometerScannerConfig(
        geminiApiKey: widget.apiKey,
        geminiModel: widget.model,
        previousReading: _lastReading,
      ),
    );
    if (reading == null || !mounted) return;

    setState(() => _history.insert(0, reading));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Saved ${reading.value} ${reading.unit.symbol}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasKey = widget.apiKey.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('My Vehicle')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: hasKey ? _scan : null,
        icon: const Icon(Icons.document_scanner_rounded),
        label: const Text('Scan odometer'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          if (!hasKey)
            Card(
              color: scheme.errorContainer,
              child: ListTile(
                leading: Icon(Icons.key_off_rounded, color: scheme.error),
                title: const Text('Gemini API key missing'),
                subtitle: const Text(
                  'Run with --dart-define=GEMINI_API_KEY=<your key>',
                ),
              ),
            ),
          Card(
            elevation: 0,
            color: scheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current odometer',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _lastReading?.toString() ?? '— — —',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('History', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (_history.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'No readings yet. Tap “Scan odometer” to add one.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          for (final r in _history)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.speed_rounded)),
              title: Text('${r.value} ${r.unit.symbol}'),
              subtitle: Text(
                '${MaterialLocalizations.of(context).formatMediumDate(r.capturedAt)}'
                ' · ${(r.confidence * 100).round()}% confidence',
              ),
            ),
        ],
      ),
    );
  }
}
