import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logistix/core/presentation/widgets/location_text_field.dart';
import 'package:logistix/features/form_validator/application/form_validator_rp.dart';
import 'package:logistix/features/form_validator/application/textfield_validators.dart';
import 'package:logistix/features/quick_actions/presentation/pages/quick_action_base_dialog.dart';
import 'package:logistix/core/presentation/widgets/order_fare_widget.dart';
import 'package:logistix/core/presentation/widgets/price_selector_widget.dart';
import 'package:logistix/features/quick_actions/domain/quick_actions_types.dart';

class SubmitFoodQAData extends QADialogData {
  final String description;
  final String price;
  final String dropoff;
  final String pickup;

  SubmitFoodQAData({
    required this.description,
    required this.price,
    required this.dropoff,
    required this.pickup,
  });
}

class SubmitFoodQADialog extends QAConsumerStatefulDialog<SubmitFoodQAData> {
  const SubmitFoodQADialog({super.key, super.initialData});

  @override
  QAConsumerState<SubmitFoodQADialog> createState() => _FoodQASectionState();
}

class _FoodQASectionState extends QAConsumerState<SubmitFoodQADialog> {
  final descriptionTEC = TextEditingController();
  final priceTEC = TextEditingController();
  final dropoffTEC = TextEditingController();
  final pickupTEC = TextEditingController();

  @override
  void initState() {
    if (widget.initialData != null) {
      descriptionTEC.text = widget.initialData!.description;
      priceTEC.text = widget.initialData!.price;
      dropoffTEC.text = widget.initialData!.dropoff;
      pickupTEC.text = widget.initialData!.pickup;
    }
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

  void pageOne() {
    final group = FormValidatorGroup(ref, [
      requiredValidatorProvider(descriptionTEC),
      requiredValidatorProvider(dropoffTEC),
      requiredValidatorProvider(pickupTEC),
    ]);

    if (group.validateAndCheck()) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void pageTwo() {
    final group = FormValidatorGroup(ref, [
      requiredValidatorProvider(priceTEC),
    ]);

    if (group.validateAndCheck()) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return QADialogBase(
      pageController: pageController,
      action: QuickAction.food,
      pages: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              textValidatorProviderFornCardBuilder(
                validatorProvider: requiredValidatorProvider(dropoffTEC),
                title: "Dropoff Location *",
                child: LocationTextField(
                  controller: dropoffTEC,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 12 Lekki Phase 1',
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textValidatorProviderFornCardBuilder(
                validatorProvider: requiredValidatorProvider(priceTEC),
                title: "Budget (₦) *",
                child: PriceSelectorField(controller: priceTEC),
              ),
              const SizedBox(height: 32),
              OrderFareWidget(
                farePrice: r'N5.3k - N20k',
                eta: '20-30min',
                color: QuickAction.food.color.withAlpha(40),
              ),
            ],
          ),
        ),
      ],
      footerBuilder: (pageIndex, status) {
        return ElevatedButton(
          onPressed:
              pageIndex == 0
                  ? pageOne
                  : pageIndex == 1
                  ? pageTwo
                  : status.connectionState == ConnectionState.waiting
                  ? null
                  : onConfirm,
          child: Text(
            pageIndex == 2
                ? 'Close'
                : pageIndex == 1
                ? 'Confirm Order'
                : 'Next',
          ),
        );
      },
      onSubmit: () async {},
    );
  }
}
