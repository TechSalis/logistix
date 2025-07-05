import 'dart:async';

abstract mixin class Usecase<T> {
  FutureOr<T> call();
}
