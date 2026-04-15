// ignore_for_file: avoid_positional_boolean_parameters
import 'package:geolocator/geolocator.dart';
import 'package:shared/shared.dart';

abstract class RiderState {
  const RiderState();

  static const initial = RiderInitialState();
  static RiderState loading([Rider? rider]) => RiderLoadingState(rider);
  static RiderState loaded(Rider rider, {List<Order> orders = const [], bool isOrdersLoading = false, Position? location}) 
      => RiderLoadedState(rider, orders: orders, isOrdersLoading: isOrdersLoading, location: location);
  static RiderState error(String message) => RiderErrorState(message);

  T when<T>({
    required T Function() initial,
    required T Function(Rider? rider) loading,
    required T Function(
      Rider rider,
      List<Order> orders,
      bool isOrdersLoading,
      Position? location,
    ) loaded,
    required T Function(String message) error,
  });

  T? whenOrNull<T>({
    T? Function()? initial,
    T? Function(Rider? rider)? loading,
    T? Function(Rider rider, List<Order> orders, bool isOrdersLoading, Position? location)? loaded,
    T? Function(String message)? error,
  }) => when(
    initial: initial ?? () => null,
    loading: loading ?? (_) => null,
    loaded: (r, o, l, p) => loaded?.call(r, o, l, p),
    error: (e) => error?.call(e),
  );

  T? mapOrNull<T>({
    T? Function(RiderInitialState)? initial,
    T? Function(RiderLoadingState)? loading,
    T? Function(RiderLoadedState)? loaded,
    T? Function(RiderErrorState)? error,
  });

  T maybeMap<T>({
    required T Function() orElse, T Function(RiderInitialState)? initial,
    T Function(RiderLoadingState)? loading,
    T Function(RiderLoadedState)? loaded,
    T Function(RiderErrorState)? error,
  });
}

class RiderInitialState extends RiderState {
  const RiderInitialState();
  @override
  T when<T>({
    required T Function() initial,
    required T Function(Rider? rider) loading,
    required T Function(Rider rider, List<Order> orders, bool isOrdersLoading, Position? location) loaded,
    required T Function(String message) error,
  }) => initial();

  @override
  T? mapOrNull<T>({T? Function(RiderInitialState)? initial, T? Function(RiderLoadingState)? loading, T? Function(RiderLoadedState)? loaded, T? Function(RiderErrorState)? error}) => initial?.call(this);

  @override
  T maybeMap<T>({required T Function() orElse, T Function(RiderInitialState)? initial, T Function(RiderLoadingState)? loading, T Function(RiderLoadedState)? loaded, T Function(RiderErrorState)? error}) => initial != null ? initial(this) : orElse();
}

class RiderLoadingState extends RiderState {
  const RiderLoadingState([this.rider]);
  final Rider? rider;
  @override
  T when<T>({
    required T Function() initial,
    required T Function(Rider? rider) loading,
    required T Function(Rider rider, List<Order> orders, bool isOrdersLoading, Position? location) loaded,
    required T Function(String message) error,
  }) => loading(rider);

  @override
  T? mapOrNull<T>({T? Function(RiderInitialState)? initial, T? Function(RiderLoadingState)? loading, T? Function(RiderLoadedState)? loaded, T? Function(RiderErrorState)? error}) => loading?.call(this);

  @override
  T maybeMap<T>({required T Function() orElse, T Function(RiderInitialState)? initial, T Function(RiderLoadingState)? loading, T Function(RiderLoadedState)? loaded, T Function(RiderErrorState)? error}) => loading != null ? loading(this) : orElse();
}

class RiderLoadedState extends RiderState {

  const RiderLoadedState(this.rider, {this.orders = const [], this.isOrdersLoading = false, this.location});
  final Rider rider;
  final List<Order> orders;
  final bool isOrdersLoading;
  final Position? location;

  @override
  T when<T>({
    required T Function() initial,
    required T Function(Rider? rider) loading,
    required T Function(Rider rider, List<Order> orders, bool isOrdersLoading, Position? location) loaded,
    required T Function(String message) error,
  }) => loaded(rider, orders, isOrdersLoading, location);

  @override
  T? mapOrNull<T>({T? Function(RiderInitialState)? initial, T? Function(RiderLoadingState)? loading, T? Function(RiderLoadedState)? loaded, T? Function(RiderErrorState)? error}) => loaded?.call(this);

  @override
  T maybeMap<T>({required T Function() orElse, T Function(RiderInitialState)? initial, T Function(RiderLoadingState)? loading, T Function(RiderLoadedState)? loaded, T Function(RiderErrorState)? error}) => loaded != null ? loaded(this) : orElse();
  
  RiderLoadedState copyWith({Rider? rider, List<Order>? orders, bool? isOrdersLoading, Position? location}) {
    return RiderLoadedState(
      rider ?? this.rider,
      orders: orders ?? this.orders,
      isOrdersLoading: isOrdersLoading ?? this.isOrdersLoading,
      location: location ?? this.location,
    );
  }
}

class RiderErrorState extends RiderState {
  const RiderErrorState(this.message);
  final String message;
  @override
  T when<T>({
    required T Function() initial,
    required T Function(Rider? rider) loading,
    required T Function(Rider rider, List<Order> orders, bool isOrdersLoading, Position? location) loaded,
    required T Function(String message) error,
  }) => error(message);

  @override
  T? mapOrNull<T>({T? Function(RiderInitialState)? initial, T? Function(RiderLoadingState)? loading, T? Function(RiderLoadedState)? loaded, T? Function(RiderErrorState)? error}) => error?.call(this);

  @override
  T maybeMap<T>({required T Function() orElse, T Function(RiderInitialState)? initial, T Function(RiderLoadingState)? loading, T Function(RiderLoadedState)? loaded, T Function(RiderErrorState)? error}) => error != null ? error(this) : orElse();
}
