import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/features/home/presentation/widgets/buttons.dart';
import 'package:logistix/features/home/presentation/widgets/text_fields.dart';
import 'package:logistix/features/form_validator/widgets/text_field_with_heading.dart';
import 'package:logistix/features/form_validator/application/textfield_validators.dart';
import 'package:logistix/features/form_validator/widgets/text_validator_provider_forn.dart';
import 'package:logistix/features/order_now/food/application/logic/food_description_order_rp.dart';

class FoodOrderPage extends StatelessWidget {
  const FoodOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text("Craving something?")),
      body: Padding(
        padding: padding_H16,
        child: FormValidatorGroupWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const _CustomOrderHero(),
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
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("Place Order"),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomOrderHero extends StatefulWidget {
  const _CustomOrderHero();

  @override
  State<_CustomOrderHero> createState() => _CustomOrderHeroState();
}

class _CustomOrderHeroState extends State<_CustomOrderHero> {
  final customOrderController = TextEditingController();
  final restaurantController = TextEditingController();
  final locationController = TextEditingController();

  @override
  void dispose() {
    customOrderController.dispose();
    restaurantController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: padding_24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFieldLabelAndErrorDisplayWidget(
              controller: customOrderController,
              validatorProvider: RequiredValidatorProvider,
              label: const Text("What do you want to eat?"),
              child: Consumer(
                builder: (context, ref, child) {
                  ref.listen(foodDescriptionOrderProvider, (p, n) {
                    customOrderController.text = n;
                  });
                  return TextField(
                    maxLines: 2,
                    controller: customOrderController,
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
              controller: restaurantController,
              validatorProvider: RequiredValidatorProvider,
              label: const Text("Restaurant (optional)"),
              child: LocationTextField(
                controller: restaurantController,
                decoration: const InputDecoration(
                  hintText: "Name or location",
                  prefixIcon: Icon(Icons.store_mall_directory_outlined),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFieldLabelAndErrorDisplayWidget(
              controller: locationController,
              validatorProvider: RequiredValidatorProvider,
              label: const Text("Delivery address"),
              child: LocationTextField(
                controller: locationController,
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
