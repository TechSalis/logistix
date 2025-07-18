import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/app/router/app_router.dart';
import 'package:logistix/features/auth/application/logic/auth_rp.dart';
import 'package:logistix/features/home/domain/entities/company_data.dart';
import 'package:logistix/features/home/application/navigation_bar_rp.dart';
import 'package:logistix/app/widgets/user_map_view.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/notifications/application/notification_service.dart';
import 'package:logistix/features/notifications/presentation/notifications/rider_found_notification_widget.dart';
import 'package:logistix/features/orders/presentation/widgets/order_icon.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';
import 'package:logistix/features/home/domain/entities/rider_data.dart';
import 'package:logistix/features/home/presentation/widgets/order_summary_card.dart';
import 'package:logistix/features/permission/application/permission_rp.dart';
import 'package:logistix/features/permission/presentation/widgets/permission_dialog.dart';
import 'package:logistix/features/rider/application/find_rider_rp.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    const Order order = Order(
      refNumber: '13276342',
      type: OrderType.delivery,
      price: 1200,
      status: OrderStatus.onTheWay,
      description: "Pick up Paracetamol from HealthPlus",
      pickUp: Address('Mozilla lodge, Akure street, Lagos'),
      dropOff: Address('Mozilla lodge, Akure street, Lagos'),
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
            final data =
                (ref.watch(
                  authProvider.select((value) {
                    return value is AuthLoggedInState ? value : null;
                  }),
                ))?.user.data;
            if (data?.name?.isEmpty ?? true) {
              return const Text("Hello, Customer 👋");
            }
            return Text("Welcome, ${data?.name} 👋");
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
            SizedBox(height: 12.h),
            const _SearchBar(),
            SizedBox(height: 16.h),
            const Expanded(child: _MiniMapWidget()),
            SizedBox(height: 32.h),
            Text("Order Now!", style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 12.h),
            const _QuickActionGrid(),
            SizedBox(height: 32.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 140.h),
              child: Consumer(
                builder: (context, ref, child) {
                  return HomeOrderSummaryCard(
                    order: order,
                    onTap: () {
                      ref.read(navBarIndexProvider.notifier).state = 1;
                    },
                  );
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
            return Column(
              children: [
                InkWell(
                  borderRadius: borderRadius_16,
                  onTap: () {
                    GoRouter.of(context).push(switch (action) {
                      OrderType.food => const FoodOrderPageRoute().location,
                      OrderType.grocery => '/${action.name}',
                      OrderType.errands => '/${action.name}',
                      OrderType.delivery =>
                        const NewDeliveryPageRoute().location,
                    });
                  },
                  child: OrderIcon(
                    type: action,
                    size: 52.w,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(action.label),
              ],
            );
          }).toList(),
    );
  }
}

class _FindRiderCTA extends ConsumerWidget {
  const _FindRiderCTA();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGranted =
        ref.watch(permissionProvider(PermissionData.location)).isGranted;
    if (isGranted == null) return const SizedBox.shrink();
    ref.listen(findRiderProvider, (p, n) {
      if (n is RiderContactedState) {
        NotificationService.inApp.show(RiderFoundNotification(rider: n.rider));
        final riderProvider = ref.read(findRiderProvider.notifier);
        Future.delayed(Durations.medium3, riderProvider.ref.invalidateSelf);
      }
    });
    return Center(
      child: ElevatedButton.icon(
        onPressed: isGranted ? () {} : null,
        icon: const Icon(Icons.flash_on),
        label: const Text("Find a Rider"),
        style: ElevatedButton.styleFrom(
          padding: padding_H12,
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
      elevation: 4,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).cardColor, width: 4),
      ),
      child: Stack(
        children: [
          const UserMapView(),
          Positioned(bottom: 12.w, right: 12.h, child: const _FindRiderCTA()),
        ],
      ),
    );
  }
}
