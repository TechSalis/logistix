import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/form_validator/widgets/text_validator_provider_forn.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/notifications/application/notification_service.dart';
import 'package:logistix/features/order_create/entities/order_request_data.dart';
import 'package:logistix/features/order_create/presentation/order_types/delivery/application/logic/delivery_order_rp.dart';
import 'package:logistix/features/orders/application/logic/orders_rp.dart';
import 'package:logistix/features/orders/domain/entities/order_responses.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

mixin CreateOrderWidgetMixin<
  D extends OrderRequestData,
  W extends ConsumerStatefulWidget
>
    on ConsumerState<W> {
  RoundedLoadingButtonController get roundedLoadingButtonController;
  ProviderSubscription<AsyncValue<int>>? _providerSub;

  D? _data;
  String? onValidate();

  void onOrderCreated(Order order);

  void validateAndCreateOrder(D newData) {
    _clearSub();
    if (_data != null) ref.invalidate(createOrderProvider(_data!));

    final validation = onValidate();
    if (validation == null) {
      roundedLoadingButtonController.start();

      _data = newData;
      _providerSub = ref.listenManual(createOrderProvider(_data!), (p, n) {
        switch (n) {
          case AsyncError():
            roundedLoadingButtonController.error();
            _clearSub();
          case AsyncData():
            roundedLoadingButtonController.success();
            final order = ref
                .read(ordersProvider.notifier)
                .addOrderFromRequest(n.requireValue, _data!);
            onOrderCreated(order);
        }
      });
    } else {
      NotificationService.inApp.showSnackbar(context, validation);
    }
  }

  void _clearSub() {
    _providerSub?.close();
    _providerSub = null;
  }

  @override
  void dispose() {
    _clearSub();
    super.dispose();
  }
}

mixin BaseCreateOrderTemplateMixin<
  D extends OrderRequestData,
  W extends ConsumerStatefulWidget
>
    on CreateOrderWidgetMixin<D, W> {
  @override
  final roundedLoadingButtonController = RoundedLoadingButtonController();

  final validatorKey = GlobalKey<FormValidatorGroupState>();

  final descriptionController = TextEditingController();
  final dropoffController = TextEditingController();
  final pickupController = TextEditingController();

  Address? pickup, dropoff;

  @override
  void dispose() {
    descriptionController.dispose();
    dropoffController.dispose();
    pickupController.dispose();
    super.dispose();
  }
}
