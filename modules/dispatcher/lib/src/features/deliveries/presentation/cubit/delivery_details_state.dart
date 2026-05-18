part of 'delivery_details_cubit.dart';

abstract class DeliveryDetailsState {
  const DeliveryDetailsState();

  const factory DeliveryDetailsState.initial() = DeliveryDetailsInitial;
  const factory DeliveryDetailsState.loading() = DeliveryDetailsLoading;
  const factory DeliveryDetailsState.loaded(Delivery delivery) = DeliveryDetailsLoaded;
  const factory DeliveryDetailsState.error(String message) = DeliveryDetailsError;

  T? whenOrNull<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(Delivery delivery)? loaded,
    T Function(String message)? error,
  }) {
    if (this is DeliveryDetailsInitial) return initial?.call();
    if (this is DeliveryDetailsLoading) return loading?.call();
    if (this is DeliveryDetailsLoaded) return loaded?.call((this as DeliveryDetailsLoaded).delivery);
    if (this is DeliveryDetailsError) return error?.call((this as DeliveryDetailsError).message);
    return null;
  }
}

class DeliveryDetailsInitial extends DeliveryDetailsState {
  const DeliveryDetailsInitial();
}

class DeliveryDetailsLoading extends DeliveryDetailsState {
  const DeliveryDetailsLoading();
}

class DeliveryDetailsLoaded extends DeliveryDetailsState {
  const DeliveryDetailsLoaded(this.delivery);
  final Delivery delivery;
}

class DeliveryDetailsError extends DeliveryDetailsState {
  const DeliveryDetailsError(this.message);
  final String message;
}
