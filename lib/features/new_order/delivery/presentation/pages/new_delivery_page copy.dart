import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/form_validator/widgets/text_validator_provider_forn.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:logistix/features/form_validator/application/form_validator_rp.dart';
import 'package:logistix/core/presentation/widgets/elevated_loading_button.dart';
import 'package:logistix/core/presentation/widgets/location_text_field.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/form_validator/application/textfield_validators.dart';

class NewDeliveryQAForm extends ConsumerStatefulWidget {
  const NewDeliveryQAForm({super.key});

  @override
  ConsumerState<NewDeliveryQAForm> createState() => _NewDeliveryQAPageState();
}

class _NewDeliveryQAPageState extends ConsumerState<NewDeliveryQAForm> {
  final pickupController = TextEditingController();
  final dropoffController = TextEditingController();
  final noteController = TextEditingController();
  final roundedLoadingButtonController = RoundedLoadingButtonController();

  Address? pickup, dropoff;

  @override
  void dispose() {
    pickupController.dispose();
    dropoffController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final validator = FormValidatorGroupWidget(ref, [
      RequiredValidatorProvider(pickupController),
      RequiredValidatorProvider(dropoffController),
      RequiredValidatorProvider(noteController),
    ]);

    if (validator.validateAndCheck()) {
      pickup ??= Address(pickupController.text, coordinates: null);
      dropoff ??= Address(dropoffController.text, coordinates: null);
      roundedLoadingButtonController.start();
      // showDialog(
      //   context: context,
      //   builder: (_) {
      //     return DeliverySummaryDialog(
      //       pickup: pickup!,
      //       dropoff: dropoff!,
      //       note: noteController.text,
      //     );
      //   },
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Delivery")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          addAutomaticKeepAlives: false,
          children: [
            TextValidatorProviderFornCard(
              validatorProvider: RequiredValidatorProvider(noteController),
              title: "Description of Item(s) *",
              child: TextFormField(
                controller: noteController,
                minLines: 3,
                maxLines: 4,
                maxLength: 255,
                decoration: const InputDecoration(
                  hintText: "e.g. 2 brand new Macbook laptops",
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextValidatorProviderFornCard(
              validatorProvider: RequiredValidatorProvider(pickupController),
              title: 'Pickup Location *',
              child: LocationTextField(
                controller: pickupController,
                decoration: const InputDecoration(
                  hintText: "Select pickup address",
                ),
                onAddressPicked: (addr) => pickup = addr,
              ),
            ),
            const SizedBox(height: 24),
            TextValidatorProviderFornCard(
              validatorProvider: RequiredValidatorProvider(dropoffController),
              title: "Drop-off Location *",
              child: LocationTextField(
                controller: dropoffController,
                decoration: const InputDecoration(
                  hintText: "Select drop-off address",
                ),
                onAddressPicked: (addr) => dropoff = addr,
              ),
            ),

            const SizedBox(height: 32),
            const OrderFareWidget(
              farePrice: 'Not available',
              eta: 'Not calculated',
            ),

            // const SizedBox(height: 24),
            // FormCard(
            //   title: "Estimated Budget (optional)",
            //   child: PriceSelectorField(controller: priceController),
            // ),
            const SizedBox(height: 48),
            ElevatedLoadingButton.icon(
              onPressed: _onSubmit,
              controller: roundedLoadingButtonController,
              icon: Icon(OrderType.delivery.icon),
              label: const Text("Confirm"),
            ),
          ],
        ),
      ),
    );
  }
}
