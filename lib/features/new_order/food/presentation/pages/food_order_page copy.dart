import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/presentation/widgets/buttons.dart';
import 'package:logistix/core/presentation/widgets/location_text_field.dart';
import 'package:logistix/features/new_order/food/application/logic/food_order_rp.dart';

class FoodOrderPage extends StatelessWidget {
  const FoodOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(title: Text("Crave something?")),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          const SliverToBoxAdapter(child: _CustomOrderHero()),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Text(
                "Popular",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: Consumer(
              builder: (context, ref, child) {
                final items = ref.watch(foodRecommendationsProvider);
                return SliverGrid.builder(
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                            .watch(foodOrderProvider.notifier)
                            .addItem(items[index]);
                      },
                    );
                  },
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.check_circle_outline),
                label: const Text("Place Order"),
              ),
            ),
          ),
        ],
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
      elevation: 2,
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What do you want to eat?",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Consumer(
              builder: (context, ref, child) {
                ref.listen(foodOrderProvider, (p, n) {
                  customOrderController.text = n;
                });
                return TextField(
                  maxLines: 2,
                  controller: customOrderController,
                  decoration: const InputDecoration(
                    hintText: "e.g. 2x catfish pepper soup, 1 chilled malt",
                    prefixIcon: Icon(Icons.edit_note),
                  ),
                  onChanged: ref.read(foodOrderProvider.notifier).updateOrder,
                );
              },
            ),
            const SizedBox(height: 12),
            LocationTextField(
              controller: restaurantController,
              decoration: const InputDecoration(
                hintText: "Restaurant (optional)",
                prefixIcon: Icon(Icons.store_mall_directory_outlined),
              ),
            ),
            const SizedBox(height: 12),
            LocationTextField(
              controller: locationController,
              decoration: const InputDecoration(
                hintText: "Delivery address",
                prefixIcon: Icon(Icons.pin_drop_outlined),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Text(item.image, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.name,
                  style: Theme.of(context).textTheme.labelSmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
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
