import 'package:flutter/foundation.dart';

/// Abstract base class for all failures in the application.
/// Failures represent expected error states that should be handled gracefully.
/// 
/// Following Clean Architecture, failures are returned from the data layer
/// and propagated up to the presentation layer for user-friendly error handling.
@immutable
abstract class Failure {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && other.message == message && other.code == code;
  }

  @override
  int get hashCode => message.hashCode ^ (code?.hashCode ?? 0);

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// Failure for local cache (Hive) operations.
/// Thrown when database initialization, read, write, or delete operations fail.
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code = 'CACHE_ERROR',
  });

  @override
  String toString() => 'CacheFailure(message: $message, code: $code)';
}

/// Failure for input validation errors.
/// Thrown when user input doesn't meet required criteria.
class ValidationFailure extends Failure {
  final String field;

  const ValidationFailure({
    required super.message,
    required this.field,
    super.code = 'VALIDATION_ERROR',
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidationFailure &&
        other.message == message &&
        other.code == code &&
        other.field == field;
  }

  @override
  int get hashCode => super.hashCode ^ field.hashCode;

  @override
  String toString() =>
      'ValidationFailure(message: $message, field: $field, code: $code)';
}

/// Failure when a requested resource is not found.
/// Thrown when attempting to access an item that doesn't exist.
class NotFoundFailure extends Failure {
  final String resourceType;
  final String? resourceId;

  const NotFoundFailure({
    required super.message,
    required this.resourceType,
    this.resourceId,
    super.code = 'NOT_FOUND',
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotFoundFailure &&
        other.message == message &&
        other.code == code &&
        other.resourceType == resourceType &&
        other.resourceId == resourceId;
  }

  @override
  int get hashCode =>
      super.hashCode ^ resourceType.hashCode ^ (resourceId?.hashCode ?? 0);

  @override
  String toString() =>
      'NotFoundFailure(message: $message, resourceType: $resourceType, resourceId: $resourceId)';
}

/// Catch-all failure for unexpected errors.
/// Used when an error doesn't fit into other categories.
class UnexpectedFailure extends Failure {
  final Object? originalError;
  final StackTrace? stackTrace;

  const UnexpectedFailure({
    required super.message,
    this.originalError,
    this.stackTrace,
    super.code = 'UNEXPECTED_ERROR',
  });

  @override
  String toString() =>
      'UnexpectedFailure(message: $message, originalError: $originalError)';
}
