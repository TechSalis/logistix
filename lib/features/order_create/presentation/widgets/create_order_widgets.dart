import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/form_validator/widgets/text_validator_provider_forn.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/notifications/application/notification_service.dart';
import 'package:logistix/features/order_create/entities/order_request_data.dart';
import 'package:logistix/features/order_create/presentation/order_types/delivery/application/logic/delivery_order_rp.dart';
import 'package:logistix/features/orders/application/logic/orders_rp.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';
import 'package:progress_state_button/progress_button.dart';

mixin CreateOrderWidgetMixin<
  D extends OrderRequestData,
  W extends ConsumerStatefulWidget
>
    on ConsumerState<W> {
  ValueNotifier<ButtonState> get buttonController;
  ProviderSubscription<AsyncValue<int>>? _providerSub;

  D? _data;
  String? onValidate();

  void onOrderCreated(Order order);

  void validateAndCreateOrder(D newData) {
    _clearSub();
    if (_data != null) ref.invalidate(createOrderProvider(_data!));

    final validation = onValidate();
    if (validation == null) {
      buttonController.value = ButtonState.loading;

      _data = newData;
      _providerSub = ref.listenManual(createOrderProvider(_data!), (p, n) {
        switch (n) {
          case AsyncError():
            buttonController.value = ButtonState.fail;
            _clearSub();
          case AsyncData():
            buttonController.value = ButtonState.success;
            final order = _data!.toOrder(refNumber: n.requireValue);
            ref.read(ordersProvider.notifier).addLocalOrder(order);
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
  final buttonController = ValueNotifier<ButtonState>(ButtonState.idle);

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
