class AppError extends Error {
  final String? error;
  final int? code;

  AppError({this.error, this.code});

  @override
  String toString() {
    return 'AppError($error, $code)';
  }
}
