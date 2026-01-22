import 'logger.dart';

/// Base exception for Recipe2Order app errors
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception for network-related errors
class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.originalError});
}

/// Exception for parsing-related errors
class ParsingException extends AppException {
  ParsingException(super.message, {super.code, super.originalError});
}

/// Exception for storage-related errors
class StorageException extends AppException {
  StorageException(super.message, {super.code, super.originalError});
}

/// Exception for validation errors
class ValidationException extends AppException {
  ValidationException(super.message, {super.code, super.originalError});
}

/// Global error handler for the app
class ErrorHandler {
  ErrorHandler._();

  /// Handle an error and return a user-friendly message
  static String handleError(Object error, {StackTrace? stackTrace}) {
    Logger.error(
      'An error occurred',
      error: error,
      stackTrace: stackTrace,
      tag: 'ErrorHandler',
    );

    if (error is AppException) {
      return error.message;
    }

    if (error is NetworkException) {
      return 'Network error. Please check your internet connection.';
    }

    if (error is ParsingException) {
      return 'Failed to parse the recipe. Please try a different format.';
    }

    if (error is StorageException) {
      return 'Failed to save data. Please try again.';
    }

    if (error is ValidationException) {
      return error.message;
    }

    // Generic error message for unexpected errors
    return 'Something went wrong. Please try again.';
  }
}
