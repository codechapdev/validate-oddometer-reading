import 'package:odometer_scanner/src/core/failures.dart';

/// Lightweight functional result type used across layer boundaries so that
/// expected errors are modelled as values instead of thrown exceptions.
sealed class Result<T> {
  const Result();

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(OdometerFailure failure) onFailure,
  }) => switch (this) {
    Success<T>(:final value) => onSuccess(value),
    Failure<T>(:final failure) => onFailure(failure),
  };
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.failure);

  final OdometerFailure failure;
}
