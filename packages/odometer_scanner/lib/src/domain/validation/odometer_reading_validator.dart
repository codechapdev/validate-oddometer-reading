import 'package:odometer_scanner/src/core/failures.dart';
import 'package:odometer_scanner/src/core/result.dart';
import 'package:odometer_scanner/src/domain/entities/odometer_analysis.dart';
import 'package:odometer_scanner/src/domain/validation/reading_validation_rule.dart';
import 'package:odometer_scanner/src/domain/validation/rules.dart';

/// Runs an ordered list of rules and returns the first violation, or the
/// parsed reading if every rule passes.
class OdometerReadingValidator {
  const OdometerReadingValidator({
    List<ReadingValidationRule> rules = defaultValidationRules,
  }) : _rules = rules;

  final List<ReadingValidationRule> _rules;

  Result<int> validate(OdometerAnalysis analysis, ValidationContext context) {
    for (final rule in _rules) {
      final failure = rule.check(analysis, context);
      if (failure != null) return Failure(failure);
    }
    final value = parseReading(analysis.reading);
    return value == null
        ? const Failure(UnreadableReadingFailure())
        : Success(value);
  }
}
