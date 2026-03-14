/// Client-side error codes for Auth module
/// These are used when the client detects invalid responses, not from server
abstract class AuthErrorCodes {
  static const String invalidResponse = 'AUTH_INVALID_RESPONSE';
  static const String missingToken = 'AUTH_MISSING_TOKEN';
  static const String invalidToken = 'AUTH_INVALID_TOKEN';
}
