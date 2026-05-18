import 'dart:async';
import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/extensions/result_extensions.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:dispatcher/src/features/deliveries/domain/repositories/delivery_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared/shared.dart';

part 'delivery_details_state.dart';

class DeliveryDetailsCubit extends Cubit<DeliveryDetailsState> {
  DeliveryDetailsCubit(this._deliveryRepository) : super(const DeliveryDetailsInitial());

  final DeliveryRepository _deliveryRepository;

  StreamSubscription<Delivery?>? _deliverySubscription;

  late final callRunner = AsyncRunner.withArg<String?, UserError, void>(
    _launchCaller,
  );
  late final markDeliveredRunner = AsyncRunner<AppError, void>(_markDelivered);
  late final cancelRunner = AsyncRunner<AppError, void>(_cancelDelivery);

  Delivery? get _currentDelivery {
    final s = state;
    return s is DeliveryDetailsLoaded ? s.delivery : null;
  }

  Future<void> _launchCaller(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    await LogistixLauncher.callNumber(phone);
  }

  void loadDelivery(String id) {
    if (isClosed) return;
    emit(const DeliveryDetailsLoading());

    _deliverySubscription?.cancel();
    _deliverySubscription = _deliveryRepository.watchDelivery(id).listen((delivery) {
      if (isClosed) return;

      if (delivery != null) {
        emit(DeliveryDetailsLoaded(delivery));
      } else if (state is! DeliveryDetailsLoaded) {
        emit(const DeliveryDetailsError('Delivery not found'));
      }
    });
  }

  Future<void> shareDelivery(Delivery delivery) async {
    final trackingLink = LogistixTracking.generateLink(
      delivery.trackingNumber,
      trackingPin: delivery.pin,
    );

    await SharePlus.instance.share(
      ShareParams(
        text: delivery.toShareText(trackingLink),
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1),
      ),
    );
  }

  @override
  Future<void> close() {
    _deliverySubscription?.cancel();
    return super.close();
  }

  late final assignRunner = AsyncRunner.withArg<Rider, AppError, void>(
    _assignRider,
  );
  late final unassignRunner = AsyncRunner<AppError, void>(_unassignRider);

  Future<void> _assignRider(Rider rider) async {
    final delivery = _currentDelivery;
    if (delivery == null || isClosed) return;

    final result = await _deliveryRepository.assignRider(delivery.id, rider);
    result.throwOrReturn();
  }

  Future<void> _unassignRider() async {
    final delivery = _currentDelivery;
    if (delivery == null || isClosed) return;

    final result = await _deliveryRepository.unassignRider(delivery.id);
    result.throwOrReturn();
  }

  Future<void> _markDelivered() async {
    final delivery = _currentDelivery;
    if (delivery == null || isClosed) return;

    final result = await _deliveryRepository.updateDeliveryStatus(
      delivery.id,
      DeliveryStatus.DELIVERED,
    );
    result.throwOrReturn();
  }

  late final rejectRunner = AsyncRunner<AppError, void>(_rejectDelivery);

  Future<void> _rejectDelivery() async {
    final delivery = _currentDelivery;
    if (delivery == null || isClosed) return;

    final result = await _deliveryRepository.rejectDelivery(delivery.id);
    result.throwOrReturn();
  }

  Future<void> _cancelDelivery() async {
    final delivery = _currentDelivery;
    if (delivery == null || isClosed) return;

    final result = await _deliveryRepository.cancelDelivery(delivery.id);
    result.throwOrReturn();
  }

  Future<void> openMap(double lat, double lng) {
    return LogistixLauncher.openMap(lat, lng);
  }
}
