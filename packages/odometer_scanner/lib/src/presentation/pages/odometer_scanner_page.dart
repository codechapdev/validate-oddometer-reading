import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odometer_scanner/src/core/odometer_scanner_config.dart';
import 'package:odometer_scanner/src/di/odometer_scanner_dependencies.dart';
import 'package:odometer_scanner/src/domain/entities/captured_image.dart';
import 'package:odometer_scanner/src/domain/entities/odometer_reading.dart';
import 'package:odometer_scanner/src/presentation/cubit/odometer_scanner_cubit.dart';
import 'package:odometer_scanner/src/presentation/widgets/analysis_progress.dart';
import 'package:odometer_scanner/src/presentation/widgets/capture_guide.dart';
import 'package:odometer_scanner/src/presentation/widgets/failure_panel.dart';
import 'package:odometer_scanner/src/presentation/widgets/image_preview.dart';
import 'package:odometer_scanner/src/presentation/widgets/reading_card.dart';
import 'package:odometer_scanner/src/presentation/widgets/scanner_action_bar.dart';

/// Full-screen scanner. By default it pops with the confirmed
/// [OdometerReading]; pass [onConfirmed] to handle the result yourself.
class OdometerScannerPage extends StatelessWidget {
  const OdometerScannerPage({
    super.key,
    required this.config,
    this.dependencies,
    this.onConfirmed,
    this.title = 'Scan odometer',
  });

  final OdometerScannerConfig config;

  /// Override to inject custom implementations (testing, custom camera…).
  final OdometerScannerDependencies? dependencies;
  final ValueChanged<OdometerReading>? onConfirmed;
  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          (dependencies ?? OdometerScannerDependencies.fromConfig(config))
              .createCubit(),
      child: OdometerScannerView(
        title: title,
        previousReading: config.previousReading,
        onConfirmed:
            onConfirmed ??
            (reading) => Navigator.of(context).pop<OdometerReading>(reading),
      ),
    );
  }
}

/// Stateless view bound to an ancestor [OdometerScannerCubit]. Exposed so
/// hosts can embed it under their own [BlocProvider].
class OdometerScannerView extends StatelessWidget {
  const OdometerScannerView({
    super.key,
    required this.onConfirmed,
    this.previousReading,
    this.title = 'Scan odometer',
  });

  final ValueChanged<OdometerReading> onConfirmed;
  final int? previousReading;
  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OdometerScannerCubit, OdometerScannerState>(
      listenWhen: (prev, curr) =>
          curr is ScannerSuccess || curr is ScannerError,
      listener: (_, state) => switch (state) {
        ScannerSuccess() => HapticFeedback.mediumImpact(),
        _ => HapticFeedback.heavyImpact(),
      },
      builder: (context, state) {
        final cubit = context.read<OdometerScannerCubit>();
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            centerTitle: true,
            actions: [
              if (state is! ScannerIdle && state is! ScannerAnalyzing)
                IconButton(
                  tooltip: 'Start over',
                  icon: const Icon(Icons.restart_alt_rounded),
                  onPressed: cubit.reset,
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: KeyedSubtree(
                key: ValueKey(state.runtimeType),
                child: _Body(state: state, previousReading: previousReading),
              ),
            ),
          ),
          bottomNavigationBar: _actionBarFor(state, cubit),
        );
      },
    );
  }

  Widget? _actionBarFor(
    OdometerScannerState state,
    OdometerScannerCubit cubit,
  ) {
    const camera = Icons.photo_camera_rounded;
    const gallery = Icons.photo_library_outlined;

    return switch (state) {
      ScannerIdle() => ScannerActionBar(
        primary: ScannerAction(
          label: 'Take photo',
          icon: camera,
          onPressed: () => cubit.capture(CaptureSource.camera),
        ),
        secondary: ScannerAction(
          label: 'Upload from gallery',
          icon: gallery,
          onPressed: () => cubit.capture(CaptureSource.gallery),
        ),
      ),
      ScannerAnalyzing() => null,
      ScannerSuccess(:final reading) => ScannerActionBar(
        primary: ScannerAction(
          label: 'Confirm reading',
          icon: Icons.check_rounded,
          onPressed: () => onConfirmed(reading),
        ),
        secondary: ScannerAction(
          label: 'Retake photo',
          icon: camera,
          onPressed: () => cubit.capture(CaptureSource.camera),
        ),
      ),
      ScannerError(:final failure, :final image)
          when !failure.isRetryableByRecapture && image != null =>
        ScannerActionBar(
          primary: ScannerAction(
            label: 'Try again',
            icon: Icons.refresh_rounded,
            onPressed: cubit.retry,
          ),
          secondary: ScannerAction(
            label: 'Retake photo',
            icon: camera,
            onPressed: () => cubit.capture(CaptureSource.camera),
          ),
        ),
      ScannerError() => ScannerActionBar(
        primary: ScannerAction(
          label: 'Retake photo',
          icon: camera,
          onPressed: () => cubit.capture(CaptureSource.camera),
        ),
        secondary: ScannerAction(
          label: 'Choose from gallery',
          icon: gallery,
          onPressed: () => cubit.capture(CaptureSource.gallery),
        ),
      ),
    };
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state, this.previousReading});

  final OdometerScannerState state;
  final int? previousReading;

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 20);
    return switch (state) {
      ScannerIdle() => CaptureGuide(previousReading: previousReading),
      ScannerAnalyzing(:final image, :final step) => Column(
        children: [
          ImagePreview(bytes: image.bytes, status: PreviewStatus.scanning),
          gap,
          AnalysisProgress(current: step),
        ],
      ),
      ScannerSuccess(:final image, :final reading) => Column(
        children: [
          ImagePreview(bytes: image.bytes, status: PreviewStatus.verified),
          gap,
          ReadingCard(reading: reading, previousReading: previousReading),
        ],
      ),
      ScannerError(:final image, :final failure) => Column(
        children: [
          if (image != null) ...[
            ImagePreview(bytes: image.bytes, status: PreviewStatus.rejected),
            gap,
          ],
          FailurePanel(failure: failure),
        ],
      ),
    };
  }
}
