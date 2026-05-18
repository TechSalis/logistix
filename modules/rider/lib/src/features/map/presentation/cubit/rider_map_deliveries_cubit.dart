import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rider/src/domain/repositories/rider_repository.dart';
import 'package:shared/shared.dart';

class RiderMapDeliveriesState {
  const RiderMapDeliveriesState({
    required this.deliveries,
    required this.isLoading,
    this.error,
  });

  factory RiderMapDeliveriesState.initial() =>
      const RiderMapDeliveriesState(deliveries: [], isLoading: false);

  final List<Delivery> deliveries;
  final bool isLoading;
  final String? error;

  RiderMapDeliveriesState copyWith({
    List<Delivery>? deliveries,
    bool? isLoading,
    String? error,
  }) {
    return RiderMapDeliveriesState(
      deliveries: deliveries ?? this.deliveries,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Cubit for displaying rider's active deliveries on the map
///
/// Subscribes to Drift stream for assigned/en-route deliveries
class RiderMapDeliveriesCubit extends Cubit<RiderMapDeliveriesState> {
  RiderMapDeliveriesCubit(this._repo) : super(RiderMapDeliveriesState.initial());
  final RiderRepository _repo;

  StreamSubscription<List<Delivery>>? _deliveriesSubscription;

  /// Initialize cubit with riderId (call after rider profile is loaded)
  void initialize() {
    _subscribeToDeliveries();
  }

  void _subscribeToDeliveries() {
    _deliveriesSubscription?.cancel();

    // Subscribe to assigned and en-route deliveries only (for map display)
    _deliveriesSubscription = _repo
        .watchRiderDeliveries(
          status: [DeliveryStatus.ASSIGNED, DeliveryStatus.EN_ROUTE],
          isPrioritySort: true, // Prioritize EN_ROUTE over ASSIGNED
        )
        .listen((deliveries) {
          if (!isClosed) {
            emit(state.copyWith(deliveries: deliveries));
          }
        });
  }

  @override
  Future<void> close() {
    _deliveriesSubscription?.cancel();
    return super.close();
  }
}
