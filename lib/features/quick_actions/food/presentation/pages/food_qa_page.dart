import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/presentation/widgets/price_selector_widget.dart';
import 'package:logistix/features/quick_actions/presentation/quick_actions_types.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:logistix/features/form_validator/application/form_validator_rp.dart';
import 'package:logistix/core/presentation/widgets/elevated_loading_button.dart';
import 'package:logistix/features/form_validator/widgets/text_validator_provider_forncard.dart';
import 'package:logistix/features/location_picker/presentation/widgets/location_text_field.dart';
import 'package:logistix/features/form_validator/application/textfield_validators.dart';
import 'package:logistix/core/presentation/widgets/order_fare_widget.dart';

class FoodQAData {
  final String description;
  final String price;
  final String dropoff;
  final String pickup;

  FoodQAData({
    required this.description,
    required this.price,
    required this.dropoff,
    required this.pickup,
  });
}

class FoodQAForm extends ConsumerStatefulWidget {
  const FoodQAForm({super.key, this.initialData});
  final FoodQAData? initialData;

  @override
  ConsumerState<FoodQAForm> createState() => _FoodQASectionState();
}

class _FoodQASectionState extends ConsumerState<FoodQAForm>
    with TextValidatorProviderFornCardBuilder {
  final descriptionTEC = TextEditingController();
  final priceTEC = TextEditingController();
  final dropoffTEC = TextEditingController();
  final pickupTEC = TextEditingController();
  final roundedLoadingButtonController = RoundedLoadingButtonController();

  @override
  void initState() {
    Future.microtask(() {
      if (widget.initialData != null) {
        descriptionTEC.text = widget.initialData!.description;
        priceTEC.text = widget.initialData!.price;
        dropoffTEC.text = widget.initialData!.dropoff;
        pickupTEC.text = widget.initialData!.pickup;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    descriptionTEC.dispose();
    priceTEC.dispose();
    dropoffTEC.dispose();
    pickupTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order Food")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          addAutomaticKeepAlives: false,
          children: [
            textValidatorProviderFornCardBuilder(
              validatorProvider: requiredValidatorProvider(descriptionTEC),
              title: "What's the order? *",
              child: TextField(
                controller: descriptionTEC,
                minLines: 2,
                maxLines: 2,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                inputFormatters: [LengthLimitingTextInputFormatter(255)],
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                decoration: const InputDecoration(
                  hintText:
                      '2x chicken suya and 1 malt.\n'
                      'You can leave a note for the rider.',
                ),
              ),
            ),
            const SizedBox(height: 24),
            textValidatorProviderFornCardBuilder(
              validatorProvider: requiredValidatorProvider(priceTEC),
              title: "Budget (₦) *",
              child: PriceSelectorField(controller: priceTEC),
            ),
            const SizedBox(height: 24),
            textValidatorProviderFornCardBuilder(
              validatorProvider: requiredValidatorProvider(pickupTEC),
              title: "Restaurant/Pickup *",
              child: LocationTextField(
                controller: pickupTEC,
                decoration: const InputDecoration(
                  hintText: 'e.g. Chicken Republic',
                ),
              ),
            ),
            const SizedBox(height: 24),
            textValidatorProviderFornCardBuilder(
              validatorProvider: requiredValidatorProvider(dropoffTEC),
              title: "Dropoff Location *",
              child: LocationTextField(
                controller: dropoffTEC,
                showUseYourLocationButton: true,
                decoration: const InputDecoration(
                  hintText: 'e.g. 12 Lekki Phase 1',
                ),
              ),
            ),

            const SizedBox(height: 32),
            OrderFareWidget(
              farePrice: r'N5.3k - N20k',
              eta: '20-30min',
              color: QuickActionType.food.color.withAlpha(40),
            ),
            const SizedBox(height: 48),
            ElevatedLoadingButton.icon(
              onPressed: () {
                final group = FormValidatorGroup(ref, [
                  requiredValidatorProvider(descriptionTEC),
                  requiredValidatorProvider(dropoffTEC),
                  requiredValidatorProvider(pickupTEC),
                  requiredValidatorProvider(priceTEC),
                ]);
                if (group.validateAndCheck()) {}
              },
              controller: roundedLoadingButtonController,
              icon: Icon(QuickActionType.food.icon),
              label: const Text("Confirm"),
            ),
          ],
        ),
      ),
    );
  }
}
