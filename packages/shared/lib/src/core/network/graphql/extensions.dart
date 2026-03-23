import 'package:bootstrap/definitions/app_error.dart';
import 'package:graphql_flutter/graphql_flutter.dart' hide ErrorHandler;
import 'package:shared/shared.dart';

extension QueryResultExtensions on QueryResult {
  /// Throws an AppError if the query result has an exception or no data.
  /// Standardizes error handling across all remote data sources.
  void throwIfException([String? fallbackMessage]) {
    if (hasException) {
      throw ErrorHandler.fromException(exception);
    }
  }

  /// Extracts data by key, throwing a UserError if null.
  T extractData<T>(String key, {String? errorMessage}) {
    throwIfException();
    
    final value = data?[key];
    if (value == null) {
      throw UserError(message: errorMessage ?? 'Server returned null for $key');
    }
    
    return value as T;
  }
}
