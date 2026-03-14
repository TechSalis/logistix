import 'dart:async';
import 'dart:io';
import 'package:bootstrap/definitions/app_error.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared/src/core/errors/error_codes.dart';

// TODO(enrico): Do not show developer errors to user.
class ErrorHandler {
  /// Convert any exception to AppError
  static AppError fromException(dynamic error, [StackTrace? stackTrace]) {
    if (error is AppError) return error;

    if (error is OperationException) {
      return _handleGraphQLError(error, stackTrace);
    }

    if (error is SocketException) {
      return UserError.network(error: error, stackTrace: stackTrace);
    }

    if (error is TimeoutException) {
      return UserError.network(
        message: 'Request timed out. Please try again.',
        error: error,
        stackTrace: stackTrace,
      );
    }

    if (error is HttpException) {
      return UserError.server(error: error, stackTrace: stackTrace);
    }

    return AppError(
      error: error,
      stackTrace: stackTrace,
      code: GraphQLErrorCodes.unknown,
    );
  }

  static AppError _handleGraphQLError(
    OperationException error,
    StackTrace? stackTrace,
  ) {
    final graphQLErrors = error.graphqlErrors;
    final linkException = error.linkException;

    if (linkException != null) {
      if (linkException is NetworkException) {
        return UserError.network(error: error, stackTrace: stackTrace);
      }

      if (linkException is ServerException) {
        return UserError.server(
          error: error,
          stackTrace: stackTrace,
          statusCode:
              linkException.parsedResponse?.response['statusCode'] as int?,
        );
      }
    }

    if (graphQLErrors.isNotEmpty) {
      final firstError = graphQLErrors.first;
      final code = firstError.extensions?['code']?.toString().toUpperCase();
      final message = firstError.message;

      return _categorizeGraphQLError(
        code: code,
        message: message,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return AppError(
      message: 'Server error. Please try again later.',
      error: error,
      stackTrace: stackTrace,
      code: GraphQLErrorCodes.unknown,
    );
  }

  static AppError _categorizeGraphQLError({
    required String message,
    required Object error,
    String? code,
    StackTrace? stackTrace,
  }) {
    if (code == null) {
      return AppError(
        message: message,
        error: error,
        stackTrace: stackTrace,
        code: GraphQLErrorCodes.unknown,
      );
    }

    // Authentication errors
    if (GraphQLErrorCodes.isAuthError(code)) {
      return UserError.authentication(
        message: message,
        error: error,
        stackTrace: stackTrace,
      );
    }

    // Authorization errors (forbidden/unauthorized)
    if (code == GraphQLErrorCodes.forbidden ||
        code == GraphQLErrorCodes.unauthorized) {
      return UserError.forbidden(
        message: message,
        error: error,
        stackTrace: stackTrace,
      );
    }

    // Not found errors
    if (GraphQLErrorCodes.isNotFoundError(code)) {
      return UserError.notFound(
        message: message,
        error: error,
        stackTrace: stackTrace,
      );
    }

    // Validation errors
    if (GraphQLErrorCodes.isValidationError(code)) {
      return ValidationError(message: message);
    }

    // Network errors
    if (GraphQLErrorCodes.isNetworkError(code)) {
      return UserError.network(
        message: message,
        error: error,
        stackTrace: stackTrace,
      );
    }

    // Server errors
    if (GraphQLErrorCodes.isServerError(code)) {
      return UserError.server(
        message: message,
        error: error,
        stackTrace: stackTrace,
      );
    }

    // Return with original code from server
    return AppError(code: code, error: error, stackTrace: stackTrace);
  }
}
