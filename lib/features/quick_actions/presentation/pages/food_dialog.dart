import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/presentation/widgets/location_text_field.dart';
import 'package:logistix/core/presentation/logic/form_validator_rp.dart';
import 'package:logistix/core/presentation/widgets/page_indicator/effects/jumping_dot_effect.dart';
import 'package:logistix/core/presentation/widgets/page_indicator/smooth_page_indicator.dart';
import 'package:logistix/features/quick_actions/presentation/logic/textfield_validators.dart';
import 'package:logistix/features/quick_actions/presentation/widgets/form_card.dart';
import 'package:logistix/features/quick_actions/presentation/widgets/order_fare_widget.dart';
import 'package:logistix/core/presentation/widgets/price_selector_widget.dart';
import 'package:logistix/features/quick_actions/presentation/quick_actions_enum.dart';
import 'package:logistix/features/quick_actions/presentation/widgets/quick_action_widget.dart';

class FoodQASection extends ConsumerStatefulWidget {
  const FoodQASection({super.key});

  @override
  ConsumerState<FoodQASection> createState() => _FoodQASectionState();
}

class _FoodQASectionState extends ConsumerState<FoodQASection> {
  final pageController = PageController();

  final descriptionTEC = TextEditingController();
  final priceTEC = TextEditingController();
  final dropoffTEC = TextEditingController();
  final pickupTEC = TextEditingController();

  @override
  void dispose() {
    pageController.dispose();
    descriptionTEC.dispose();
    priceTEC.dispose();
    dropoffTEC.dispose();
    pickupTEC.dispose();
    super.dispose();
  }

  void nextPage() {
    final group = FormValidatorGroup(ref, [
      FormValidationData(
        descriptionTEC,
        textfieldValidatorProvider(descriptionTEC),
      ),
      FormValidationData(priceTEC, textfieldValidatorProvider(priceTEC)),
    ]);

    if (group.validateAndCheck()) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousPage() {
    pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void onConfirm() {
    final group = FormValidatorGroup(ref, [
      FormValidationData(dropoffTEC, textfieldValidatorProvider(dropoffTEC)),
    ]);

    if (group.validateAndCheck()) {
      //TODO: submit food
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QuickActionIcon(action: QuickAction.food, size: 64),
              const SizedBox(height: 8),
              Text(
                'Buy Food',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 360,
                child: PageView(
                  controller: pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _errorTECFornCardProviderBuilder(
                            tec: descriptionTEC,
                            title: "What's the order? *",
                            child: TextField(
                              controller: descriptionTEC,
                              minLines: 3,
                              maxLines: 3,
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(255),
                              ],
                              onTapOutside: (event) {
                                FocusScope.of(context).unfocus();
                              },
                              decoration: const InputDecoration(
                                hintText:
                                    'e.g. 2x chicken suya and 1 malt.\n'
                                    'You can leave a note for the rider.',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _errorTECFornCardProviderBuilder(
                            tec: priceTEC,
                            title: "Budget (₦) *",
                            child: PriceSelectorField(controller: priceTEC),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _errorTECFornCardProviderBuilder(
                            tec: dropoffTEC,
                            title: "Dropoff Location *",
                            child: LocationTextField(
                              controller: dropoffTEC,
                              decoration: const InputDecoration(
                                hintText: 'e.g. 12 Lekki Phase 1',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _errorTECFornCardProviderBuilder(
                            tec: null,
                            title: "Restaurant/Pickup",
                            child: LocationTextField(
                              controller: pickupTEC,
                              decoration: const InputDecoration(
                                hintText: 'e.g. Chicken Republic',
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          OrderFareWidget(
                            farePrice: r'N5.3k - N20k',
                            eta: '20-30min',
                            color: QuickAction.food.color.withAlpha(40),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              ListenableBuilder(
                listenable: pageController,
                builder: (context, child) {
                  return AnimatedSmoothIndicator(
                    activeIndex: pageController.page?.round() ?? 0,
                    count: 2,
                    effect: JumpingDotEffect(
                      dotWidth: 8,
                      dotHeight: 8,
                      activeDotColor: Theme.of(context).colorScheme.secondary,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListenableBuilder(
                  listenable: pageController,
                  builder: (context, child) {
                    final index = pageController.page?.round() ?? 0;
                    return Row(
                      children: [
                        BackButton(onPressed: index > 0 ? previousPage : null),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: index == 0 ? nextPage : onConfirm,
                            child: Text(index == 0 ? 'Next' : 'Confirm Order'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorTECFornCardProviderBuilder({
    required TextEditingController? tec,
    required Widget child,
    required String title,
  }) {
    return Consumer(
      builder: (context, ref, child) {
        return FormCard(
          title: title,
          error:
              tec != null ? ref.watch(textfieldValidatorProvider(tec)) : null,
          child: child!,
        );
      },
      child: child,
    );
  }
}
