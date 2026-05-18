import 'dart:async';
import 'dart:io';

import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rider/src/domain/repositories/rider_repository.dart';
import 'package:shared/shared.dart';

abstract class RiderDeliveryDetailsState {
  const RiderDeliveryDetailsState();

  const factory RiderDeliveryDetailsState.initial() = RiderDeliveryDetailsInitial;
  const factory RiderDeliveryDetailsState.loading() = RiderDeliveryDetailsLoading;
  const factory RiderDeliveryDetailsState.loaded(Delivery delivery) = RiderDeliveryDetailsLoaded;
  const factory RiderDeliveryDetailsState.error(String message) = RiderDeliveryDetailsError;
}

class RiderDeliveryDetailsInitial extends RiderDeliveryDetailsState {
  const RiderDeliveryDetailsInitial();
}

class RiderDeliveryDetailsLoading extends RiderDeliveryDetailsState {
  const RiderDeliveryDetailsLoading();
}

class RiderDeliveryDetailsLoaded extends RiderDeliveryDetailsState {
  const RiderDeliveryDetailsLoaded(this.delivery);
  final Delivery delivery;
}

class RiderDeliveryDetailsError extends RiderDeliveryDetailsState {
  const RiderDeliveryDetailsError(this.message);
  final String message;
}

class RiderDeliveryDetailsCubit extends Cubit<RiderDeliveryDetailsState> {
  RiderDeliveryDetailsCubit(this._riderRepository)
    : super(const RiderDeliveryDetailsInitial());

  final RiderRepository _riderRepository;
  
  StreamSubscription<Delivery?>? _deliverySubscription;

  late final unassignRunner = AsyncRunner<AppError, void>(_unassignDelivery);
  late final markDeliveredRunner = AsyncRunner<AppError, void>(_markDelivered);
  late final startDeliveryRunner = AsyncRunner<AppError, void>(_startDelivery);

  // New runner for delivery with proof
  File? _pendingProofImage;

  Future<void> deliverWithProof(File image) async {
    _pendingProofImage = image;
    await markDeliveredRunner.call();
    _pendingProofImage = null;
  }

  Future<void> _startDelivery() async {
    final curState = state;
    if (curState is RiderDeliveryDetailsLoaded) {
      final result = await _riderRepository.updateDeliveryStatus(
        curState.delivery.id,
        DeliveryStatus.EN_ROUTE,
      );

      result.when(
        error: (error) {
          throw UserError(
            message: error.message ?? 'Failed to start delivery',
          );
        },
      );
    }
  }

  void loadDelivery(String deliveryId, {Delivery? initialDelivery}) {
    if (initialDelivery != null) {
      emit(RiderDeliveryDetailsLoaded(initialDelivery));
    } else {
      emit(const RiderDeliveryDetailsLoading());
    }

    // Subscribe to delivery stream from Drift
    _deliverySubscription?.cancel();
    _deliverySubscription = _riderRepository
        .watchDelivery(deliveryId)
        .listen(
          (delivery) {
            if (isClosed) return;

            if (delivery != null) {
              emit(RiderDeliveryDetailsLoaded(delivery));
            } else if (state is! RiderDeliveryDetailsLoaded) {
              emit(const RiderDeliveryDetailsError('Delivery not found'));
            }
          },
          onError: (Object error) {
            if (isClosed) return;
            emit(
              RiderDeliveryDetailsError(
                (error is UserError ? error.message : null) ??
                    'Failed to load delivery tracking info',
              ),
            );
          },
        );
  }

  @override
  Future<void> close() {
    _deliverySubscription?.cancel();
    return super.close();
  }

  Future<void> updateStatus(DeliveryStatus status, {String? pin, String? proofImageUrl}) async {
    final curState = state;
    if (curState is RiderDeliveryDetailsLoaded) {
      final result = await _riderRepository.updateDeliveryStatus(
        curState.delivery.id,
        status,
        pin: pin,
        proofImageUrl: proofImageUrl,
      );

      if (isClosed) return;

      result.when(
        error: (error) {
          throw UserError(
            message: error.message ?? 'Failed to update delivery status',
          );
        },
      );
    }
  }

  Future<void> _unassignDelivery() async {
    final curState = state;
    if (curState is RiderDeliveryDetailsLoaded) {
      final result = await _riderRepository.updateDeliveryStatus(
        curState.delivery.id,
        DeliveryStatus.PENDING,
      );

      if (isClosed) return;

      result.when(
        error: (error) {
          throw UserError(
            message: error.message ?? 'Failed to unassign delivery',
          );
        },
      );
    }
  }

  Future<void> _markDelivered() async {
    final curState = state;
    if (curState is RiderDeliveryDetailsLoaded) {
      String? proofImageUrl;

      if (_pendingProofImage != null) {
        final uploadResult = await _riderRepository.uploadProofOfDelivery(
          curState.delivery.id,
          _pendingProofImage!,
        );

        uploadResult.when(
          data: (url) => proofImageUrl = url,
          error: (error) {
            throw UserError(
              message: error.message ?? 'Failed to upload proof of delivery image',
            );
          },
        );
      }

      final result = await _riderRepository.updateDeliveryStatus(
        curState.delivery.id,
        DeliveryStatus.DELIVERED,
        proofImageUrl: proofImageUrl,
      );

      if (isClosed) return;

      result.when(
        error: (error) {
          throw UserError(
            message: error.message ?? 'Failed to mark delivery as delivered',
          );
        },
      );
    }
  }

  Future<void> openMap(double lat, double lng) async {
    await LogistixLauncher.openMap(lat, lng);
  }
}
