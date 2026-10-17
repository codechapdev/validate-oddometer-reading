import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:odometer_scanner/odometer_scanner.dart';

class _MockCubit extends MockCubit<OdometerScannerState>
    implements OdometerScannerCubit {}

void main() {
  final image = CapturedImage(
    path: '/tmp/odo.png',
    bytes: img.encodePng(img.Image(width: 8, height: 6)),
    mimeType: 'image/png',
  );
  final reading = OdometerReading(
    value: 45120,
    unit: DistanceUnit.kilometers,
    confidence: 0.93,
    imagePath: image.path,
    capturedAt: DateTime(2026),
  );

  Future<void> pump(WidgetTester tester, OdometerScannerState state) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final cubit = _MockCubit();
    whenListen(
      cubit,
      const Stream<OdometerScannerState>.empty(),
      initialState: state,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<OdometerScannerCubit>.value(
          value: cubit,
          child: OdometerScannerView(
            onConfirmed: (_) {},
            previousReading: 40000,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('idle shows guide and capture actions', (tester) async {
    await pump(tester, const ScannerIdle());
    expect(find.text('Capture your odometer'), findsOneWidget);
    expect(find.text('Take photo'), findsOneWidget);
    expect(find.text('Last recorded: 40,000'), findsOneWidget);
  });

  testWidgets('analyzing shows progress and no actions', (tester) async {
    await pump(
      tester,
      ScannerAnalyzing(image: image, step: AnalysisStep.readingOdometer),
    );
    expect(find.text('Reading odometer with AI'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('success shows reading and confirm', (tester) async {
    await pump(tester, ScannerSuccess(image: image, reading: reading));
    expect(find.text('Confirm reading'), findsOneWidget);
    expect(find.text('93%'), findsOneWidget);
    expect(find.text('+5,120 since last reading'), findsOneWidget);
  });

  testWidgets('error shows failure copy and retake', (tester) async {
    await pump(
      tester,
      ScannerError(failure: const BlurryImageFailure(), image: image),
    );
    expect(find.text('Image is blurry'), findsOneWidget);
    expect(find.text('Retake photo'), findsOneWidget);
  });

  testWidgets('network error offers retry', (tester) async {
    await pump(
      tester,
      ScannerError(failure: const NetworkFailure(), image: image),
    );
    expect(find.text('Try again'), findsOneWidget);
  });
}
