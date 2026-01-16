/// Custom exception for cache (Hive) operations.
/// Thrown when local database operations fail and should be caught
/// at the repository layer and converted to [CacheFailure].
class CacheException implements Exception {
  final String message;
  final Object? originalError;

  const CacheException({
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'CacheException: $message';
}

/// Exception thrown when a requested resource is not found.
/// Should be caught at the repository layer and converted to [NotFoundFailure].
class NotFoundException implements Exception {
  final String message;
  final String resourceType;
  final String? resourceId;

  const NotFoundException({
    required this.message,
    required this.resourceType,
    this.resourceId,
  });

  @override
  String toString() =>
      'NotFoundException: $message (type: $resourceType, id: $resourceId)';
}

/// Exception thrown when input validation fails.
/// Should be caught at the repository layer and converted to [ValidationFailure].
class ValidationException implements Exception {
  final String message;
  final String field;

  const ValidationException({
    required this.message,
    required this.field,
  });

  @override
  String toString() => 'ValidationException: $message (field: $field)';
}
