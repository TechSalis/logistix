import 'dart:async';

import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rider/src/domain/repositories/rider_repository.dart';
import 'package:rider/src/domain/usecases/manage_rider_session_usecase.dart';
import 'package:rider/src/presentation/bloc/rider_event.dart';
import 'package:rider/src/presentation/bloc/rider_state.dart';
import 'package:shared/shared.dart' hide RiderEvent;
import 'package:url_launcher/url_launcher.dart';

class RiderBloc extends Bloc<RiderEvent, RiderState> {
  RiderBloc(this._repository, this._sessionUseCase, this._logoutUseCase)
    : super(const RiderState.initial()) {
    on<FetchProfile>(_onFetchProfile);
    on<RefreshStatus>(_onRefreshStatus);
    on<FetchOrders>(_onFetchOrders);
    on<OrderAssigned>(_onOrderAssigned);
    on<OrderUpdated>(_onOrderUpdated);
    on<OrderUnassigned>(_onOrderUnassigned);
    on<MetricsUpdated>(_onMetricsUpdated);
    on<LocationUpdated>(_onLocationUpdated);
  }

  final RiderRepository _repository;
  final RiderSessionManager _sessionUseCase;
  final LogoutUseCase _logoutUseCase;

  // Callback for metrics updates
  void Function(RiderMetrics)? onMetricsUpdated;

  Future<void> _onOrderAssigned(
    OrderAssigned event,
    Emitter<RiderState> emit,
  ) async {
    state.mapOrNull(
      loaded: (s) {
        final newOrders = List<Order>.from(s.orders)..insert(0, event.order);
        emit(s.copyWith(orders: newOrders));
      },
    );
  }

  Future<void> _onOrderUpdated(
    OrderUpdated event,
    Emitter<RiderState> emit,
  ) async {
    state.mapOrNull(
      loaded: (s) {
        final newOrders = List<Order>.from(s.orders);
        final idx = newOrders.indexWhere((o) => o.id == event.order.id);
        if (idx != -1) {
          newOrders[idx] = event.order;
        } else {
          newOrders.insert(0, event.order);
        }
        emit(s.copyWith(orders: newOrders));
      },
    );
  }

  Future<void> _onOrderUnassigned(
    OrderUnassigned event,
    Emitter<RiderState> emit,
  ) async {
    state.mapOrNull(
      loaded: (s) {
        final newOrders = List<Order>.from(s.orders)
          ..removeWhere((o) => o.id == event.orderId);
        emit(s.copyWith(orders: newOrders));
      },
    );
  }

  Future<void> _onMetricsUpdated(
    MetricsUpdated event,
    Emitter<RiderState> emit,
  ) async {
    // Forward metrics to RiderOrdersCubit via callback
    onMetricsUpdated?.call(event.metrics);
  }

  Future<void> _onLocationUpdated(
    LocationUpdated event,
    Emitter<RiderState> emit,
  ) async {
    state.mapOrNull(loaded: (s) => emit(s.copyWith(location: event.position)));
  }

  Future<void> _onFetchOrders(
    FetchOrders event,
    Emitter<RiderState> emit,
  ) async {
    await state.mapOrNull(
      loaded: (state) async {
        emit(state.copyWith(isOrdersLoading: true));

        final result = await _repository.getRiderOrders(
          status: event.status,
          limit: event.limit,
          offset: event.offset,
        );

        result.when(
          data: (orders) {
            emit(state.copyWith(orders: orders, isOrdersLoading: false));
          },
          error: (_) => emit(state.copyWith(isOrdersLoading: false)),
        );
      },
    );
  }

  Future<void> _onFetchProfile(
    FetchProfile event,
    Emitter<RiderState> emit,
  ) async {
    emit(const RiderState.loading());

    final result = await _repository.getRiderProfile();
    result.when(
      data: (rider) {
        emit(RiderState.loaded(rider));

        _sessionUseCase.start(
          riderId: rider.id,
          onOrderAssigned: (order) {
            if (!isClosed) add(OrderAssigned(order));
          },
          onOrderUpdated: (order) {
            if (!isClosed) add(OrderUpdated(order));
          },
          onOrderUnassigned: (orderId) {
            if (!isClosed) add(OrderUnassigned(orderId));
          },
          onMetricsUpdated: (metrics) {
            if (!isClosed) add(MetricsUpdated(metrics));
          },
          onLocationUpdated: (position) {
            if (!isClosed) add(LocationUpdated(position));
          },
        );
      },
      error: (error) {
        emit(
          RiderState.error(
            (error is UserError ? error.message : null) ??
                'Failed to fetch profile',
          ),
        );
      },
    );
  }

  Future<void> _onRefreshStatus(
    RefreshStatus event,
    Emitter<RiderState> emit,
  ) async {
    state.maybeMap(
      loaded: (state) => emit(state.copyWith(isRefreshing: true)),
      orElse: () => emit(const RiderState.loading()),
    );

    final result = await _repository.getRiderProfile();
    result.map((error) {
      emit(RiderState.error(error.message ?? 'Failed to refresh status'));
    }, (rider) => emit(RiderState.loaded(rider)));
  }

  late final logoutEvent = AsyncRunner<AppError, void>(_logoutUseCase.call);

  late final supportRunner = AsyncRunner.withArg<String, AppError, void>(
    _launchSupportUrl,
  );

  Future<void> _launchSupportUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw const UserError(message: 'Could not open support link');
    }
  }

  @override
  Future<void> close() {
    _sessionUseCase.stop();
    return super.close();
  }
}
