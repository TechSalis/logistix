import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/form_validator/widgets/text_validator_provider_forn.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/order_create/entities/order_request_data.dart';
import 'package:logistix/features/order_create/presentation/order_types/delivery/application/logic/delivery_order_rp.dart';
import 'package:logistix/features/orders/application/logic/orders_rp.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

mixin CreateOrderWidgetMixin<
  D extends OrderRequestData,
  W extends ConsumerStatefulWidget
>
    on ConsumerState<W> {
  D? data;
  ProviderSubscription? _providerSub;

  RoundedLoadingButtonController get roundedLoadingButtonController;
  String? onValidate();

  void validateAndCreateOrder(D newData) {
    _clearSub();
    final validation = onValidate();
    if (validation == null) {
      setState(() => data = newData);
      _providerSub = ref.listenManual(createOrderProvider(data!), (p, n) {
        switch (n) {
          case AsyncLoading():
            roundedLoadingButtonController.start();
            break;
          case AsyncError():
            roundedLoadingButtonController.error();
            _clearSub();
          case AsyncData():
            ref
                .read(ordersProvider.notifier)
                .addLocalOrder(n.requireValue.value, data!);
            roundedLoadingButtonController.success();
            data = null;
        }
      });
    } else {
      setState(() => data = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validation)));
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
