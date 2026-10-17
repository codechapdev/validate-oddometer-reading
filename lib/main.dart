import 'package:flutter/material.dart';
import 'package:odometer_poc/home_page.dart';

/// Inject at build/run time — never commit keys:
/// flutter run --dart-define=GEMINI_API_KEY=xxx [--dart-define=GEMINI_MODEL=...]
const _geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
const _geminiModel = String.fromEnvironment(
  'GEMINI_MODEL',
  defaultValue: 'gemini-flash-latest',
);

void main() => runApp(const OdometerPocApp());

class OdometerPocApp extends StatelessWidget {
  const OdometerPocApp({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme(Brightness brightness) => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2F5BEA),
        brightness: brightness,
      ),
    );

    return MaterialApp(
      title: 'Odometer POC',
      debugShowCheckedModeBanner: false,
      theme: theme(Brightness.light),
      darkTheme: theme(Brightness.dark),
      home: const HomePage(apiKey: _geminiApiKey, model: _geminiModel),
    );
  }
}
