import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/form_validator/widgets/text_validator_provider_forn.dart';
import 'package:logistix/features/home/application/home_rp.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/notifications/application/notification_service.dart';
import 'package:logistix/features/order_create/application/create_order_rp.dart';
import 'package:logistix/features/order_create/domain/entities/order_request_data.dart';
import 'package:logistix/features/order_create/infrastructure/dtos/create_order_dto.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';
import 'package:progress_state_button/progress_button.dart';

mixin CreateOrderWidgetMixin<
  Request extends OrderRequestData,
  Widget extends ConsumerStatefulWidget
>
    on ConsumerState<Widget>, BaseCreateOrderTemplateMixin {
  ProviderSubscription<AsyncValue<CreateOrderResponse>>? _providerSub;

  Request? _data;
  String? onValidate();
  void onOrderCreated(Order order);

  bool get fieldsValid =>
      validatorKey.currentState!.validateAndCheck() &&
      (pickup != null && dropoff != null);

  void validateAndCreateOrder(Request newData) {
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
          case AsyncData():
            buttonController.value = ButtonState.success;

            final order = _data!.toOrder(
              orderId: n.requireValue.orderId,
              refNumber: n.requireValue.refNumber,
            );
            
            ref.read(homeProvider.notifier).updateOrderPreview(order);
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
    disposeFields();
    super.dispose();
  }
}

mixin BaseCreateOrderTemplateMixin {
  final validatorKey = GlobalKey<FormValidatorGroupState>();

  final buttonController = ValueNotifier<ButtonState>(ButtonState.idle);
  final descriptionController = TextEditingController();
  final dropoffController = TextEditingController();
  final pickupController = TextEditingController();

  Address? pickup, dropoff;

  void disposeFields() {
    buttonController.dispose();
    descriptionController.dispose();
    dropoffController.dispose();
    pickupController.dispose();
  }
}
