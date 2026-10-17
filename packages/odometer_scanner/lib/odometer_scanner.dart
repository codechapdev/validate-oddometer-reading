/// Reusable odometer capture + AI verification module.
library;

export 'src/core/failures.dart';
export 'src/core/odometer_scanner_config.dart';
export 'src/core/result.dart';
export 'src/di/odometer_scanner_dependencies.dart';
export 'src/domain/entities/captured_image.dart';
export 'src/domain/entities/odometer_analysis.dart';
export 'src/domain/entities/odometer_reading.dart';
export 'src/domain/repositories/odometer_repository.dart';
export 'src/domain/services/image_capture_service.dart';
export 'src/domain/services/image_quality_checker.dart';
export 'src/domain/usecases/analyze_odometer_image.dart';
export 'src/domain/validation/odometer_reading_validator.dart';
export 'src/domain/validation/reading_validation_rule.dart';
export 'src/domain/validation/rules.dart';
export 'src/odometer_scanner.dart';
export 'src/presentation/cubit/odometer_scanner_cubit.dart';
export 'src/presentation/pages/odometer_scanner_page.dart';
