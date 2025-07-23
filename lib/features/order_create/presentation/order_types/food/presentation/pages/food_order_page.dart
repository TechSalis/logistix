import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/app/widgets/buttons.dart';
import 'package:logistix/app/widgets/text_fields.dart';
import 'package:logistix/features/form_validator/widgets/text_field_with_heading.dart';
import 'package:logistix/features/form_validator/application/textfield_validators.dart';
import 'package:logistix/features/form_validator/widgets/text_validator_provider_forn.dart';
import 'package:logistix/features/order_create/entities/order_request_data.dart';
import 'package:logistix/features/order_create/presentation/order_types/food/application/logic/food_description_order_rp.dart';
import 'package:logistix/features/order_create/presentation/widgets/create_order_widgets.dart';
import 'package:logistix/features/orders/domain/entities/base_order_data.dart';
import 'package:logistix/features/orders/domain/entities/order_responses.dart';

class FoodOrderPage extends ConsumerStatefulWidget {
  const FoodOrderPage({super.key});

  @override
  ConsumerState<FoodOrderPage> createState() => _FoodOrderPageState();
}

class _FoodOrderPageState extends ConsumerState<FoodOrderPage>
    with CreateOrderWidgetMixin, BaseCreateOrderTemplateMixin {
  @override
  String? onValidate() {
    /// Validates the form fields and checks if all images are uploaded
    final fieldsValidated =
        validatorKey.currentState!.validateAndCheck() &&
        (pickup != null && dropoff != null);
    if (!fieldsValidated) {
      // Fields are not valid
      return 'Please fill all required fields.';
    }
    return null;
  }

  @override
  void onOrderCreated(Order order) {
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text("Craving something?")),
      body: Padding(
        padding: padding_H16,
        child: FormValidatorGroupWidget(
          key: validatorKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _CustomOrderHero(orderTemplateMixin: this),
              const SizedBox(height: 32),
              Text("Popular", style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final items = ref.watch(foodRecommendationsProvider);
                    return GridView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 8,
                            childAspectRatio: 4,
                          ),
                      itemBuilder: (context, index) {
                        return _MiniFoodCard(
                          item: items[index],
                          onItemAdded: () {
                            ref
                                .watch(foodDescriptionOrderProvider.notifier)
                                .addItem(items[index]);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedLoadingButton.icon(
                  controller: roundedLoadingButtonController,
                  onPressed: () {
                    validateAndCreateOrder(
                      OrderRequestData(
                        description: descriptionController.text.trim(),
                        pickup: pickup,
                        dropoff: dropoff,
                        orderType: OrderType.food,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("Place Order"),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomOrderHero extends StatefulWidget {
  const _CustomOrderHero({required this.orderTemplateMixin});
  final BaseCreateOrderTemplateMixin orderTemplateMixin;

  @override
  State<_CustomOrderHero> createState() => _CustomOrderHeroState();
}

class _CustomOrderHeroState extends State<_CustomOrderHero> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: padding_24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFieldLabelAndErrorDisplayWidget(
              controller: widget.orderTemplateMixin.descriptionController,
              validatorProvider: RequiredValidatorProvider,
              label: const Text("What do you want to eat?"),
              child: Consumer(
                builder: (context, ref, child) {
                  ref.listen(foodDescriptionOrderProvider, (p, n) {
                    widget.orderTemplateMixin.descriptionController.text = n;
                  });
                  return TextField(
                    maxLines: 2,
                    controller: widget.orderTemplateMixin.descriptionController,
                    decoration: const InputDecoration(
                      hintText: "e.g. 2x catfish pepper soup, 1 chilled malt",
                      prefixIcon: Icon(Icons.edit_note),
                    ),
                    onChanged: (value) {
                      ref
                          .read(foodDescriptionOrderProvider.notifier)
                          .updateOrder(value);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            TextFieldLabelAndErrorDisplayWidget(
              controller: widget.orderTemplateMixin.pickupController,
              validatorProvider: RequiredValidatorProvider,
              label: const Text("Restaurant (optional)"),
              child: AddressTextField(
                heroTag: 'restaurant',
                onAddressChanged: (value) {
                  widget.orderTemplateMixin.pickupController.text = value.name;
                  widget.orderTemplateMixin.pickup = value;
                },
                decoration: const InputDecoration(
                  hintText: "Name or location",
                  prefixIcon: Icon(Icons.store_mall_directory_outlined),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFieldLabelAndErrorDisplayWidget(
              controller: widget.orderTemplateMixin.dropoffController,
              validatorProvider: RequiredValidatorProvider,
              label: const Text("Delivery address"),
              child: AddressTextField(
                heroTag: 'location',
                onAddressChanged: (value) {
                  widget.orderTemplateMixin.dropoffController.text = value.name;
                  widget.orderTemplateMixin.dropoff = value;
                },
                decoration: const InputDecoration(
                  hintText: "Delivery address",
                  prefixIcon: Icon(Icons.pin_drop_outlined),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniFoodCard extends StatelessWidget {
  const _MiniFoodCard({required this.item, required this.onItemAdded});

  final FoodRecommendationItem item;
  final VoidCallback onItemAdded;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onItemAdded,
      child: Card(
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Text(item.image, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.name,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(height: 1.2),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 4),
              const CustomTextButton(child: Text("Add")),
            ],
          ),
        ),
      ),
    );
  }
}
