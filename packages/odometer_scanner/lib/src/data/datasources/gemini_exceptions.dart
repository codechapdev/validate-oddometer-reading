/// Data-layer exceptions; mapped to domain failures by the repository.
sealed class GeminiException implements Exception {
  const GeminiException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class GeminiHttpException extends GeminiException {
  const GeminiHttpException(this.statusCode, super.message);

  final int statusCode;
}

final class GeminiBlockedException extends GeminiException {
  const GeminiBlockedException(super.message);
}

final class GeminiMalformedResponseException extends GeminiException {
  const GeminiMalformedResponseException(super.message);
}
