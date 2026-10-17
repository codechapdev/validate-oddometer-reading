import 'package:flutter/material.dart';
import 'package:odometer_scanner/odometer_scanner.dart';

/// Inject at build/run time — never commit keys:
/// flutter run --dart-define=GEMINI_API_KEY=xxx
const _geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'odometer_scanner example',
    theme: ThemeData(colorSchemeSeed: const Color(0xFF2F5BEA)),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
        geminiApiKey: _geminiApiKey,
        // New readings must not be lower than the last confirmed one.
        previousReading: _lastReading,
      ),
    );
    if (reading == null || !mounted) return;
    setState(() => _history.insert(0, reading));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('My Vehicle')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _geminiApiKey.isEmpty ? null : _scan,
      icon: const Icon(Icons.document_scanner_rounded),
      label: const Text('Scan odometer'),
    ),
    body: ListView(
      children: [
        if (_geminiApiKey.isEmpty)
          const ListTile(
            leading: Icon(Icons.key_off_rounded),
            title: Text('Gemini API key missing'),
            subtitle: Text('Run with --dart-define=GEMINI_API_KEY=<your key>'),
          ),
        for (final r in _history)
          ListTile(
            leading: const Icon(Icons.speed_rounded),
            title: Text('${r.value} ${r.unit.symbol}'),
            subtitle: Text('${(r.confidence * 100).round()}% confidence'),
          ),
      ],
    ),
  );
}
