/// Prompt and response schema for Gemini. Kept separate so it can be tuned
/// without touching transport code.
abstract final class OdometerPrompt {
  static const String systemInstruction = '''
You are a strict vehicle-inspection assistant that verifies odometer photos for insurance and fleet audits.

Analyse the image and report:
1. isOdometer: true only if a vehicle instrument cluster odometer (total distance) is clearly the subject.
2. isImageClear: false if the digits are blurred, out of focus, motion-blurred, pixelated, too dark or washed out by glare.
3. reading: the TOTAL odometer reading as digits only (no separators, no units).
   - Ignore trip meters (TRIP, TRIP A/B), fuel range, speed, clock, temperature and RPM values.
   - For mechanical/analog drums, ignore the tenths digit (usually a different colour or after a decimal point).
   - If ANY digit is uncertain, set reading to null. Never guess.
4. unit: "km", "mi" or "unknown".
5. displayType: "digital", "analog" or "unknown".
6. confidence: 0.0 - 1.0, your confidence that "reading" is exactly correct.
7. issues: zero or more of
   "blurry", "glare", "too_dark", "partially_visible", "obstructed",
   "not_an_odometer", "trip_meter_only", "screen_or_edited"
   - use "trip_meter_only" when only a trip value is shown and no ODO value is visible.
   - use "screen_or_edited" when the photo is of another screen/monitor, a printout, or appears digitally edited.
8. remarks: one short, user-friendly sentence describing the main problem, or null.

Respond with JSON only.''';

  static const String userPrompt = 'Verify this odometer photo.';

  static const Map<String, Object> responseSchema = {
    'type': 'OBJECT',
    'properties': {
      'isOdometer': {'type': 'BOOLEAN'},
      'isImageClear': {'type': 'BOOLEAN'},
      'reading': {'type': 'STRING', 'nullable': true},
      'unit': {
        'type': 'STRING',
        'enum': ['km', 'mi', 'unknown'],
      },
      'displayType': {
        'type': 'STRING',
        'enum': ['digital', 'analog', 'unknown'],
      },
      'confidence': {'type': 'NUMBER'},
      'issues': {
        'type': 'ARRAY',
        'items': {
          'type': 'STRING',
          'enum': [
            'blurry',
            'glare',
            'too_dark',
            'partially_visible',
            'obstructed',
            'not_an_odometer',
            'trip_meter_only',
            'screen_or_edited',
          ],
        },
      },
      'remarks': {'type': 'STRING', 'nullable': true},
    },
    'required': [
      'isOdometer',
      'isImageClear',
      'reading',
      'unit',
      'displayType',
      'confidence',
      'issues',
    ],
    'propertyOrdering': [
      'isOdometer',
      'isImageClear',
      'reading',
      'unit',
      'displayType',
      'confidence',
      'issues',
      'remarks',
    ],
  };
}
