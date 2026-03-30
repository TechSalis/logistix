/// Error codes expected from GraphQL/Network responses
/// These match what the backend sends in error.extensions.code
abstract class GraphQLErrorCodes {
  // Authentication/Authorization - from GraphQL errors
  static const String auth = 'AUTH';
  static const String unauthenticated = 'UNAUTHENTICATED';
  static const String forbidden = 'FORBIDDEN';
  static const String unauthorized = 'UNAUTHORIZED';

  // Not Found - from GraphQL errors
  static const String notFound = 'NOT_FOUND';

  // Validation - from GraphQL errors
  static const String validation = 'VALIDATION';
  static const String badUserInput = 'BAD_USER_INPUT';

  // Network/Server - from GraphQL errors
  static const String network = 'NETWORK';
  static const String timeout = 'TIMEOUT';
  static const String server = 'SERVER';
  static const String internal = 'INTERNAL';

  // Generic fallback
  static const String unknown = 'UNKNOWN_ERROR';

  /// Check if code indicates an auth error
  static bool isAuthError(String? code) {
    if (code == null) return false;
    final upper = code.toUpperCase();
    return (upper.contains(auth) && upper != forbidden) ||
        upper == unauthenticated ||
        upper == unauthorized;
  }

  /// Check if code indicates a permission/access denied error
  static bool isForbidden(String? code) {
    if (code == null) return false;
    return code.toUpperCase().contains(forbidden);
  }

  /// Check if code indicates a not found error
  static bool isNotFoundError(String? code) {
    if (code == null) return false;
    return code.toUpperCase().contains(notFound);
  }

  /// Check if code indicates a validation error
  static bool isValidationError(String? code) {
    if (code == null) return false;
    final upper = code.toUpperCase();
    return upper.contains(validation) || upper.contains(badUserInput);
  }

  /// Check if code indicates a network error
  static bool isNetworkError(String? code) {
    if (code == null) return false;
    final upper = code.toUpperCase();
    return upper.contains(network) || upper.contains(timeout);
  }

  /// Check if code indicates a server error
  static bool isServerError(String? code) {
    if (code == null) return false;
    final upper = code.toUpperCase();
    return upper.contains(server) || upper.contains(internal);
  }
}
