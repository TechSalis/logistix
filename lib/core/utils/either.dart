/// Either is a sum type that can represent two possible states,
/// Left and Right. It is commonly used in functional programming.
///
/// In Dart, it can be used to represent a value that might be
/// absent or present, such as the result of a calculation that
/// might overflow.
///
/// [fail] and [success] are both optional, and exactly one of them
/// is always null.
class Either<F, S> {
  final F? fail;
  final S? success;

  const Either._({this.fail, this.success})
    : assert(
        fail == null || success == null,
        'Only one of fail or success can be non-null.',
      );

  /// Creates a new [Either] that contains the [value].
  factory Either.fail(F value) => Either._(fail: value);

  /// Creates a new [Either] that contains the [value].
  factory Either.success(S value) => Either._(success: value);

  /// Returns whether the value is Left.
  bool get isFail => fail != null;

  /// Returns whether the value is Right.
  bool get isSuccess => success != null;

  /// Returns the value of the Left if the value is Left, otherwise
  /// throws a [StateError].
  F get failValue => isFail ? fail! : throw StateError('Not a Fail.');

  /// Returns the value of the Right if the value is Right, otherwise
  /// throws a [StateError].
  S get successValue => isSuccess ? success! : throw StateError('Not a Success.');

  T fold<T>(
    T Function(F value) fail,
    T Function(S value) success,
  ) {
    return isFail ? fail(failValue) : success(successValue);
  }

  T? ifAny<T>({
    T Function(F value)? fail,
    T Function(S value)? success,
  }) {
    return isFail ? fail?.call(failValue) : success?.call(successValue);
  }

  @override
  String toString() => isFail ? 'Fail($fail)' : 'Success($success)';
}
