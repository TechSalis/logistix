import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/app/router/app_router.dart';
import 'package:logistix/core/utils/extensions/widget_extensions.dart';
import 'package:logistix/features/auth/application/logic/auth_rp.dart';
import 'package:logistix/features/home/application/home_rp.dart';
import 'package:logistix/app/widgets/user_map_view.dart';
import 'package:logistix/features/map/application/user_location_rp.dart';
import 'package:logistix/features/orders/presentation/widgets/order_cards.dart';
import 'package:logistix/features/orders/presentation/widgets/order_icon.dart';
import 'package:logistix/features/orders/domain/entities/base_order_data.dart';
import 'package:logistix/features/permission/application/permission_rp.dart';
import 'package:logistix/features/permission/presentation/widgets/base_permission_dialog.dart';
import 'package:logistix/features/rider/presentation/pages/find_rider_dialog.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
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
            const _SearchBar(),
            SizedBox(height: 16.h),
            const Expanded(child: _MiniMapWidget()),
            SizedBox(height: 32.h),
            Text(
              "Order Now!",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12.h),
            const _QuickActionGrid(),
            SizedBox(height: 32.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 150.h),
              child: Consumer(
                builder: (context, ref, child) {
                  final provider = ref.watch(homeProvider);
                  final isLoading =
                      provider.isLoading &&
                      provider.value?.orderPreview == null;
                  return AnimatedCrossFade(
                    duration: Durations.medium2,
                    alignment: Alignment.center,
                    crossFadeState:
                        isLoading
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                    secondChild: const Center(
                      child: CircularProgressIndicator(),
                    ),
                    firstChild: OrderPreviewCard(
                      order: provider.value!.orderPreview,
                    ),
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
                    // TODO: Create other order type pages
                    GoRouter.of(context).push(
                      switch (action) {
                        OrderType.food => const FoodOrderPageRoute(),
                        OrderType.grocery => const NewDeliveryPageRoute(),
                        OrderType.errands => const NewDeliveryPageRoute(),
                        OrderType.delivery => const NewDeliveryPageRoute(),
                      }.location,
                    );
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

    ref.watch(locationProvider.notifier).getUserCoordinates();
    return Center(
      child: ElevatedButton.icon(
        onPressed: isGranted ? () => showFindRiderDialog(context) : null,
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
      elevation: context.isLightTheme ? 4 : 0,
      clipBehavior: Clip.hardEdge,
      // shape: RoundedRectangleBorder(
      //   side: BorderSide(
      //     color:
      //         context.isLightTheme ? Colors.white : AppColors.greyMat.shade800,
      //     width: 4,
      //   ),
      // ),
      child: Stack(
        children: [
          const UserMapView(),
          Positioned(bottom: 12.w, right: 12.h, child: const _FindRiderCTA()),
        ],
      ),
    );
  }
}
