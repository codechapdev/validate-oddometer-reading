import 'package:equatable/equatable.dart';

/// Every failure the module can surface. Each failure carries user-facing
/// copy so that any host UI can render it consistently.
sealed class OdometerFailure extends Equatable {
  const OdometerFailure({
    required this.title,
    required this.message,
    this.hints = const [],
  });

  final String title;
  final String message;

  /// Actionable suggestions shown to the user to fix the problem.
  final List<String> hints;

  /// Whether retaking the photo is likely to resolve the failure.
  bool get isRetryableByRecapture => true;

  @override
  List<Object?> get props => [runtimeType, title, message, hints];
}

final class BlurryImageFailure extends OdometerFailure {
  const BlurryImageFailure()
    : super(
        title: 'Image is blurry',
        message:
            'We could not see the odometer clearly. Please retake the photo.',
        hints: const [
          'Hold your phone steady or rest it on the steering wheel',
          'Tap the screen to focus on the odometer before capturing',
          'Make sure the lens is clean',
        ],
      );
}

final class PoorLightingFailure extends OdometerFailure {
  const PoorLightingFailure({String? detail})
    : super(
        title: 'Poor lighting or glare',
        message:
            detail ??
            'The digits are hidden by glare, reflections or low light.',
        hints: const [
          'Turn the ignition on so the display is lit',
          'Tilt the phone slightly to avoid reflections',
          'Avoid using flash directly on the dashboard glass',
        ],
      );
}

final class NotAnOdometerFailure extends OdometerFailure {
  const NotAnOdometerFailure()
    : super(
        title: 'No odometer found',
        message: "This photo doesn't appear to show a vehicle odometer.",
        hints: const [
          'Point the camera at the instrument cluster',
          'Fill most of the frame with the odometer display',
        ],
      );
}

final class TripMeterOnlyFailure extends OdometerFailure {
  const TripMeterOnlyFailure()
    : super(
        title: 'Trip meter detected',
        message:
            'Only the trip meter is visible. We need the total odometer (ODO) reading.',
        hints: const [
          'Press the trip/ODO button to switch the display to ODO',
          'Make sure the label "ODO" is visible in the photo',
        ],
      );
}

final class UnreadableReadingFailure extends OdometerFailure {
  const UnreadableReadingFailure()
    : super(
        title: "Can't read the digits",
        message:
            'The odometer is visible but some digits are obstructed or cut off.',
        hints: const [
          'Make sure every digit is inside the frame',
          'Move closer so the numbers are large and sharp',
        ],
      );
}

final class LowConfidenceFailure extends OdometerFailure {
  const LowConfidenceFailure({required int confidencePercent})
    : super(
        title: 'Reading is uncertain',
        message:
            'We read the odometer with only $confidencePercent% '
            'confidence. Please retake a clearer photo.',
        hints: const [
          'Get closer and keep the display parallel to the camera',
          'Avoid shadows across the digits',
        ],
      );
}

final class ReadingBelowPreviousFailure extends OdometerFailure {
  const ReadingBelowPreviousFailure({
    required int reading,
    required int previous,
  }) : super(
         title: 'Reading is lower than before',
         message:
             'Detected $reading, but the last recorded reading was $previous. '
             'Odometer readings can never decrease.',
         hints: const [
           'Check that you photographed the ODO and not the trip meter',
           'Make sure no digit is hidden or misread',
         ],
       );
}

final class ReadingOutOfRangeFailure extends OdometerFailure {
  const ReadingOutOfRangeFailure({required int reading, required int max})
    : super(
        title: 'Reading looks incorrect',
        message:
            'Detected $reading, which exceeds the allowed maximum of $max.',
        hints: const ['Retake the photo so every digit is clearly visible'],
      );
}

final class SuspiciousImageFailure extends OdometerFailure {
  const SuspiciousImageFailure()
    : super(
        title: 'Photo could not be verified',
        message:
            'This looks like a photo of a screen or an edited image. '
            'Please photograph the actual dashboard.',
        hints: const ['Capture the odometer directly from the vehicle'],
      );
}

final class NetworkFailure extends OdometerFailure {
  const NetworkFailure()
    : super(
        title: 'No internet connection',
        message: 'We need an internet connection to verify the reading.',
        hints: const ['Check your connection and try again'],
      );

  @override
  bool get isRetryableByRecapture => false;
}

final class AiServiceFailure extends OdometerFailure {
  const AiServiceFailure({String? detail})
    : super(
        title: 'Verification service unavailable',
        message: detail ?? 'Something went wrong while analysing the photo.',
        hints: const ['Please try again in a moment'],
      );

  @override
  bool get isRetryableByRecapture => false;
}

final class ImagePickFailure extends OdometerFailure {
  const ImagePickFailure({String? detail})
    : super(
        title: "Couldn't open camera",
        message: detail ?? 'Please allow camera / photo access and try again.',
        hints: const ['Enable the permission from your device settings'],
      );
}
