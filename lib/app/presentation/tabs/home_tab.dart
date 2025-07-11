import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/core/utils/router.dart';
import 'package:logistix/features/auth/application/logic/auth_rp.dart';
import 'package:logistix/app/domain/entities/company_data.dart';
import 'package:logistix/app/application/navigation_bar_rp.dart';
import 'package:logistix/app/presentation/widgets/user_map_view.dart';
import 'package:logistix/features/orders/presentation/widgets/order_icon.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';
import 'package:logistix/app/domain/entities/rider_data.dart';
import 'package:logistix/features/orders/presentation/widgets/order_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final Order? order = Order(
      id: '13276',
      type: OrderType.delivery,
      price: 1200,
      status: OrderStatus.enRoute,
      description: "Pick up Paracetamol from HealthPlus, deliver to Yaba",
      rider: RiderData(
        id: 'id',
        name: 'name',
        imageUrl: 'imageUrl',
        phone: 'phone',
        company: CompanyData(id: 'id', name: ''),
        rating: 4.5,
      ),
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Consumer(
          builder: (context, ref, _) {
            final user = (ref.watch(authProvider) as AuthLoggedIn).user;
            if (user.data.name?.isEmpty ?? true) {
              return const Text("Hello, Customer 👋");
            }
            return Text("Welcome, ${user.data.name} 👋");
          },
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: padding_H16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SearchBar(),
            SizedBox(height: 16.h),
            const Expanded(child: _MiniMapWidget()),
            SizedBox(height: 16.h),
            const _FindRiderCTA(),
            SizedBox(height: 16.h),
            Text("Order Now", style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 12.h),
            const _QuickActionGrid(),
            SizedBox(height: 24.h),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  if (order == null) {
                    return const _EmptyOrderPrompt();
                  } else {
                    return _LastOrderCard(
                      order: order,
                      eta: "6 mins",
                      onViewDetails: () {
                        ref.read(navBarIndexProvider.notifier).state = 1;
                      },
                      // onTrack: order.rider == null ? null : () {},
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 12.h),
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
      decoration: const InputDecoration(
        hintText: 'Track an order (Link or #ID)',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: borderRadius_12),
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
              onTap: () {
                GoRouter.of(context).push(switch (action) {
                  OrderType.food => const FoodOrderPageRoute().location,
                  OrderType.grocery => '/${action.name}',
                  OrderType.errands => '/${action.name}',
                  OrderType.delivery => const NewDeliveryPageRoute().location,
                });
              },

              child: Column(
                children: [
                  OrderIcon(
                    type: action,
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
  final String? eta;
  final VoidCallback onViewDetails;
  // final VoidCallback? onTrack;

  const _LastOrderCard({
    required this.order,
    required this.eta,
    required this.onViewDetails,
    // this.onTrack,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: padding_H16_V8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            Text(
              "🕓 Last Order: #${order.id}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              order.description,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            SizedBox(height: 8.h),
            RepaintBoundary(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "Status: ",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          // color: order.status.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      OrderStatusChip(status: order.status),
                    ],
                  ),
                  if (eta != null)
                    Text.rich(
                      TextSpan(
                        text: "ETA: ",
                        children: [
                          TextSpan(
                            text: eta,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // if (onTrack != null)
                //   Padding(
                //     padding: const EdgeInsets.only(right: 12),
                //     child: ElevatedButton.icon(
                //       onPressed: onTrack,
                //       icon: const Icon(Icons.location_pin),
                //       label: const Text("Track"),
                //       style: Theme.of(
                //         context,
                //       ).elevatedButtonTheme.style?.copyWith(
                //         iconSize: const WidgetStatePropertyAll(16),
                //         minimumSize: const WidgetStatePropertyAll(Size(0, 36)),
                //         textStyle: WidgetStatePropertyAll(
                //           Theme.of(context).textTheme.bodySmall,
                //         ),
                //         padding: const WidgetStatePropertyAll(
                //           EdgeInsets.symmetric(horizontal: 12),
                //         ),
                //       ),
                //     ),
                //   ),
                OutlinedButton(
                  onPressed: onViewDetails,
                  style: Theme.of(context).outlinedButtonTheme.style?.copyWith(
                    minimumSize: const WidgetStatePropertyAll(Size(0, 36)),
                    textStyle: WidgetStatePropertyAll(
                      Theme.of(context).textTheme.bodySmall,
                    ),
                    padding: const WidgetStatePropertyAll(padding_H12),
                  ),
                  child: const Text("View Order"),
                ),
              ],
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
        padding: padding_24,
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

class _FindRiderCTA extends StatelessWidget {
  const _FindRiderCTA();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.flash_on),
        label: const Text("Find a Rider"),
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.tertiary,
        ),
      ),
    );
  }
}

class _MiniMapWidget extends StatelessWidget {
  const _MiniMapWidget();

  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: 1,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: borderRadius_12),
      child: UserMapView(),
    );
  }
}
