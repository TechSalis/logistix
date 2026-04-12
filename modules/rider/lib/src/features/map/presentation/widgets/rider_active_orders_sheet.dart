import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:rider/src/presentation/router/rider_routes.dart';
import 'package:shared/shared.dart';

class RiderActiveOrdersSheet extends StatelessWidget {
  const RiderActiveOrdersSheet({
    required this.activeOrders,
    required this.sheetAnimationController,
    required this.handleScaleAnimation,
    required this.onAnimateToLocation,
    required this.onLocationSelectedChanged,
    super.key,
  });

  final List<Order> activeOrders;
  final AnimationController sheetAnimationController;
  final Animation<double> handleScaleAnimation;
  final ValueChanged<LatLng> onAnimateToLocation;
  final ValueChanged<bool> onLocationSelectedChanged;

  @override
  Widget build(BuildContext context) {
    final smallest = 100 / MediaQuery.heightOf(context);
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        // Animate handle when dragging
        if (notification.extent > 0.1 && notification.extent < 0.75) {
          if (sheetAnimationController.status != AnimationStatus.forward) {
            sheetAnimationController.forward();
          }
        } else {
          if (sheetAnimationController.status != AnimationStatus.reverse) {
            sheetAnimationController.reverse();
          }
        }
        return false;
      },
      child: DraggableScrollableSheet(
        snap: true,
        shouldCloseOnMinExtent: false,
        minChildSize: smallest,
        maxChildSize: 0.8,
        initialChildSize: activeOrders.isEmpty ? smallest : 0.35,
        snapSizes: activeOrders.isEmpty
            ? [smallest, 0.4]
            : [smallest, 0.35, 0.8],
        builder: (context, scrollController) {
          return AnimatedBuilder(
            animation: sheetAnimationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: 0.1 + (sheetAnimationController.value * 0.08),
                      ),
                      blurRadius: 10 + (sheetAnimationController.value * 8),
                      offset: Offset(
                        0,
                        -8 - (sheetAnimationController.value * 4),
                      ),
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: BootstrapSpacing.sm),
                      AnimatedBuilder(
                        animation: handleScaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: handleScaleAnimation.value,
                            child: Container(
                              width: 40,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          );
                        },
                      ),
                      AnimatedBuilder(
                        animation: sheetAnimationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale:
                                1.0 + (sheetAnimationController.value * 0.04),
                            child: child,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: BootstrapSpacing.lg,
                            vertical: BootstrapSpacing.sm,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(
                                  BootstrapSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: LogistixColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.assignment_rounded,
                                  color: LogistixColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: BootstrapSpacing.sm),
                              Text(
                                'Active Orders',
                                style: context.textTheme.titleMedium?.bold,
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: BootstrapSpacing.sm,
                                  vertical: BootstrapSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: LogistixColors.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${activeOrders.length}',
                                  style: context.textTheme.labelMedium?.bold
                                      .copyWith(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (activeOrders.isEmpty)
                  _EmptyOrdersSliver()
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      BootstrapSpacing.md,
                      0,
                      BootstrapSpacing.md,
                      BootstrapSpacing.lg,
                    ),
                    sliver: SliverList.separated(
                      itemCount: activeOrders.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: BootstrapSpacing.sm),
                      itemBuilder: (context, index) {
                        final order = activeOrders[index];
                        return _AnimatedOrderCard(
                          order: order,
                          index: index,
                          onAnimateToLocation: onAnimateToLocation,
                          onLocationSelectedChanged: onLocationSelectedChanged,
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyOrdersSliver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.all(BootstrapSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(BootstrapSpacing.lg),
              decoration: BoxDecoration(
                color: LogistixColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.task_alt_rounded,
                size: 48,
                color: LogistixColors.primary.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: BootstrapSpacing.md),
            Text(
              'No Active Orders',
              style: context.textTheme.titleMedium?.bold.copyWith(
                color: LogistixColors.textSecondary,
              ),
            ),
            const SizedBox(height: BootstrapSpacing.xs),
            Text(
              'New assignments will appear here',
              style: context.textTheme.bodyMedium?.copyWith(
                color: LogistixColors.textSecondary.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedOrderCard extends StatelessWidget {
  const _AnimatedOrderCard({
    required this.order,
    required this.index,
    required this.onAnimateToLocation,
    required this.onLocationSelectedChanged,
  });

  final Order order;
  final int index;
  final ValueChanged<LatLng> onAnimateToLocation;
  final ValueChanged<bool> onLocationSelectedChanged;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: OrderPreviewCard(
        order: order,
        onTap: () =>
            context.push(RiderRoutes.orderDetails(order.id), extra: order),
        action: order.hasPickupPosition
            ? AnimatedScaleTap(
                onTap: () {
                  final targetLocation = LatLng(
                    order.pickupLat!,
                    order.pickupLng!,
                  );
                  onAnimateToLocation(targetLocation);
                  onLocationSelectedChanged(false);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: BootstrapSpacing.sm,
                    vertical: BootstrapSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: LogistixColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: LogistixColors.primary,
                      ),
                      const SizedBox(width: BootstrapSpacing.xxs),
                      Text(
                        'MAP',
                        style: context.textTheme.labelSmall?.bold.copyWith(
                          color: LogistixColors.primary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
