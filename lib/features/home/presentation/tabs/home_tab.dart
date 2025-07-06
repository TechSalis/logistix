import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix/features/home/presentation/widgets/user_map_view.dart';
import 'package:logistix/features/new_order/widgets/order_icon.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';
import 'package:logistix/features/rider/domain/entities/rider.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    const Order? order = Order(
      id: '13276',
      type: OrderType.delivery,
      price: 1200,
      status: OrderStatus.enRoute,
      summary: "Pick up Paracetamol from HealthPlus, deliver to Yaba",
      description: "Pick up Paracetamol from HealthPlus, deliver to Yaba",
      rider: Rider(id: 'id', name: 'name', company: 'company', rating: 4),
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Welcome, Eric 👋"),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SearchBar(),
            const SizedBox(height: 24),
            const Expanded(child: _MiniMapWidget()),
            const SizedBox(height: 12),
            const _CallHelperCTA(),
            const SizedBox(height: 32),
            Text("Order Now", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            const _QuickActionGrid(),
            const SizedBox(height: 24),
            if (order != null)
              SizedBox(
                height: 160,
                child: _LastOrderCard(
                  order: order,
                  eta: "6 mins",
                  onReorder: () {},
                  onTrack: order.rider == null ? null : () {},
                ),
              )
            else //TODO: if (find rider != null)
              // _FindRiderWidget(rider: rider)
              const SizedBox(height: 160, child: _EmptyOrderPrompt()),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      decoration: InputDecoration(
        hintText: 'Track an order (Link or #ID)',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children:
          OrderType.values.map((action) {
            return GestureDetector(
              onTap: () => GoRouter.of(context).push('/${action.name}'),
              child: Column(
                children: [
                  OrderIcon(
                    action: action,
                    size: 52,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    action.label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}

class _LastOrderCard extends StatelessWidget {
  final Order order;
  final String eta;
  final VoidCallback onReorder;
  final VoidCallback? onTrack;

  const _LastOrderCard({
    required this.order,
    required this.eta,
    required this.onReorder,
    this.onTrack,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              "🕓 Last Order: #${order.id}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              order.summary,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(
                  TextSpan(
                    text: "Status: ",
                    children: [
                      TextSpan(
                        text: order.status.label,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: order.status.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: "ETA: ",
                    children: [
                      TextSpan(
                        text: eta,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.green),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButtonTheme(
              data: ElevatedButtonThemeData(
                style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                  iconSize: const WidgetStatePropertyAll(16),
                  minimumSize: const WidgetStatePropertyAll(Size(0, 36)),
                  textStyle: WidgetStatePropertyAll(
                    Theme.of(context).textTheme.bodySmall,
                  ),
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              child: OutlinedButtonTheme(
                data: OutlinedButtonThemeData(
                  style: Theme.of(context).outlinedButtonTheme.style?.copyWith(
                    minimumSize: const WidgetStatePropertyAll(Size(0, 36)),
                    textStyle: WidgetStatePropertyAll(
                      Theme.of(context).textTheme.bodySmall,
                    ),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onTrack != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ElevatedButton.icon(
                          onPressed: onTrack,
                          icon: const Icon(Icons.location_pin),
                          label: const Text("Track"),
                        ),
                      ),
                    OutlinedButton(
                      onPressed: onReorder,
                      child: const Text("Reorder"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyOrderPrompt extends StatelessWidget {
  const _EmptyOrderPrompt();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.local_shipping,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              "No active orders",
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "You can create a new order above.",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CallHelperCTA extends StatelessWidget {
  const _CallHelperCTA();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.flash_on),
        label: const Text("Find a Rider"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.tertiary,
        ),
      ),
    );
  }
}

class _MiniMapWidget extends StatelessWidget {
  const _MiniMapWidget();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: const AbsorbPointer(child: UserMapView()),
    );
  }
}
