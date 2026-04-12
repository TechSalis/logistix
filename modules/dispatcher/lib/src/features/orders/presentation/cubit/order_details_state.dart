part of 'order_details_cubit.dart';

abstract class OrderDetailsState {
  const OrderDetailsState();

  const factory OrderDetailsState.initial() = OrderDetailsInitial;
  const factory OrderDetailsState.loading() = OrderDetailsLoading;
  const factory OrderDetailsState.loaded(Order order) = OrderDetailsLoaded;
  const factory OrderDetailsState.error(String message) = OrderDetailsError;

  T? whenOrNull<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(Order order)? loaded,
    T Function(String message)? error,
  }) {
    if (this is OrderDetailsInitial) return initial?.call();
    if (this is OrderDetailsLoading) return loading?.call();
    if (this is OrderDetailsLoaded) return loaded?.call((this as OrderDetailsLoaded).order);
    if (this is OrderDetailsError) return error?.call((this as OrderDetailsError).message);
    return null;
  }
}

class OrderDetailsInitial extends OrderDetailsState {
  const OrderDetailsInitial();
}

class OrderDetailsLoading extends OrderDetailsState {
  const OrderDetailsLoading();
}

class OrderDetailsLoaded extends OrderDetailsState {
  const OrderDetailsLoaded(this.order);
  final Order order;
}

class OrderDetailsError extends OrderDetailsState {
  const OrderDetailsError(this.message);
  final String message;
}
