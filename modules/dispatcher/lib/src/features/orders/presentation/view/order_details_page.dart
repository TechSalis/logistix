import 'package:dispatcher/src/domain/repositories/order_repository.dart';
import 'package:dispatcher/src/features/orders/presentation/cubit/order_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          OrderDetailsCubit(context.read<OrderRepository>())
            ..loadOrder(orderId),
      child: _OrderDetailsView(orderId),
    );
  }
}

class _OrderDetailsView extends StatelessWidget {
  const _OrderDetailsView(this.orderId);

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LogistixColors.background,
      body: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const _OrderDetailsShimmer(),
            error: (message) => LogistixErrorView(
              message: message,
              onRetry: () =>
                  context.read<OrderDetailsCubit>().loadOrder(orderId),
            ),
            loaded: (order) => _OrderLoadedContent(order: order),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
        builder: (context, state) {
          return state.maybeWhen(
            loaded: (order) => _BottomActionCta(order: order),
            orElse: () => const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

class _OrderLoadedContent extends StatelessWidget {
  const _OrderLoadedContent({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _SliverAppBar(order: order),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              LogistixSpacing.lg,
              LogistixSpacing.xl,
              LogistixSpacing.lg,
              LogistixSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OrderHeader(order: order, dateFormat: dateFormat),
                const SizedBox(height: LogistixSpacing.xl),
                const _SectionTitle(title: 'DELIVERY DETAILS'),
                const SizedBox(height: LogistixSpacing.md),
                _InfoCard(
                  title: 'Pickup Address',
                  content: order.pickupAddress,
                  icon: Icons.trip_origin_rounded,
                  iconColor: LogistixColors.primary,
                ),
                const SizedBox(height: LogistixSpacing.md),
                if (order.dropOffAddress != null) ...[
                  _InfoCard(
                    title: 'Drop-off Address',
                    content: order.dropOffAddress!,
                    icon: Icons.flag_rounded,
                    iconColor: Colors.orange,
                  ),
                  const SizedBox(height: LogistixSpacing.md),
                ],
                if (order.items != null) ...[
                  _InfoCard(
                    title: 'Package Items',
                    content: order.items!,
                    icon: Icons.inventory_2_rounded,
                  ),
                  const SizedBox(height: LogistixSpacing.md),
                ],
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _InfoCard(
                        title: 'Customer',
                        content: order.customerName ?? 'Unknown Customer',
                        icon: Icons.person_rounded,
                        onIconTap: order.customerPhone != null
                            ? () => context
                                  .read<OrderDetailsCubit>()
                                  .callRunner
                                  .call(order.customerPhone)
                            : null,
                      ),
                    ),
                    const SizedBox(width: LogistixSpacing.md),
                    Expanded(
                      flex: 2,
                      child: _InfoCard(
                        title: 'COD',
                        content: order.codAmount != null
                            ? '₩${order.codAmount!.toStringAsFixed(0)}'
                            : 'None',
                        icon: Icons.payments_rounded,
                        iconColor: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: LogistixSpacing.xl),
                _RiderSection(order: order),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SliverAppBar extends StatelessWidget {
  const _SliverAppBar({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final isRiderAssigned = order.rider != null;
    final hasRiderLocation = order.rider?.hasLocation ?? false;
    final isEnRoute = order.status == OrderStatus.enRoute;

    // Show rider location when rider is assigned and order is en route
    final shouldShowRiderLocation =
        isRiderAssigned && isEnRoute && hasRiderLocation;

    final displayLocation = shouldShowRiderLocation
        ? LatLng(order.rider!.lastLat!, order.rider!.lastLng!)
        : null;

    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      stretch: true,
      backgroundColor: LogistixColors.background,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            if (displayLocation != null)
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: displayLocation,
                  zoom: 15,
                ),
                markers: {
                  // Show order icon at rider's location when en route
                  Marker(
                    markerId: const MarkerId('rider_with_order'),
                    position: displayLocation,
                    infoWindow: InfoWindow(
                      title: '${order.rider!.fullName} - En Route',
                      snippet:
                          'Delivering to '
                          '${order.dropOffAddress ?? order.pickupAddress}',
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueOrange,
                      // Use orange for order/delivery
                    ),
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                compassEnabled: false,
                mapToolbarEnabled: false,
              )
            else
              Container(
                width: double.infinity,
                color: LogistixColors.surface,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: LogistixColors.primary.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        shouldShowRiderLocation
                            ? Icons.location_searching_rounded
                            : Icons.map_outlined,
                        size: 48,
                        color: LogistixColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      shouldShowRiderLocation
                          ? 'Rider Location Unavailable'
                          : isRiderAssigned
                          ? 'Waiting for Rider to Start'
                          : 'No Rider Assigned',
                      style: context.textTheme.labelLarge?.copyWith(
                        color: LogistixColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Delivery Address: ${order.pickupAddress}',
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: LogistixColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            // Gradient Overlays
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),
            // Real-time indicator when showing rider location
            if (shouldShowRiderLocation)
              Positioned(
                top: 60,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'LIVE TRACKING',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
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

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({required this.order, required this.dateFormat});

  final Order order;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ORDER OVERVIEW',
                style: context.textTheme.labelSmall?.copyWith(
                  color: LogistixColors.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '#${order.trackingNumber}',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: LogistixColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: LogistixColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateFormat.format(order.createdAt.toLocal()),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: LogistixColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _StatusBadge(status: order.status),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w900,
        color: LogistixColors.textTertiary,
        letterSpacing: 1,
      ),
    );
  }
}

class _RiderSection extends StatelessWidget {
  const _RiderSection({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final rider = order.rider;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'RIDER ASSIGNMENT'),
        const SizedBox(height: LogistixSpacing.md),
        if (rider != null)
          AnimatedScaleTap(
            onTap: () {
              // Navigate to rider profile
            },
            child: Container(
              padding: const EdgeInsets.all(LogistixSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(LogistixRadii.lg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: LogistixColors.border.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  _AvatarWithName(rider: rider),
                  const SizedBox(width: LogistixSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rider.fullName,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        _RiderStatusIndicator(status: rider.status),
                      ],
                    ),
                  ),
                  if (rider.phoneNumber != null)
                    IconButton.filledTonal(
                      onPressed: () => context
                          .read<OrderDetailsCubit>()
                          .callRunner(rider.phoneNumber),
                      icon: const Icon(Icons.phone_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: LogistixColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        foregroundColor: LogistixColors.primary,
                      ),
                    ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: LogistixColors.textTertiary,
                  ),
                ],
              ),
            ),
          )
        else
          AnimatedScaleTap(
            onTap: () => _showAssignRiderDialog(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: LogistixColors.primary.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(LogistixRadii.lg),
                border: Border.all(
                  color: LogistixColors.primary.withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: LogistixColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_add_rounded,
                      color: LogistixColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assign a Rider',
                          style: context.textTheme.titleMedium?.copyWith(
                            color: LogistixColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Tap to select a professional rider',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: LogistixColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: LogistixColors.primary,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _AvatarWithName extends StatelessWidget {
  const _AvatarWithName({required this.rider});
  final Rider rider;

  @override
  Widget build(BuildContext context) {
    // Check if there's a profile image, else show initials or icon
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            LogistixColors.primary,
            LogistixColors.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.person_rounded, color: Colors.white, size: 30),
    );
  }
}

class _RiderStatusIndicator extends StatelessWidget {
  const _RiderStatusIndicator({required this.status});
  final RiderStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status == RiderStatus.online ? Colors.green : Colors.grey;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              if (status == RiderStatus.online)
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          status.name.toUpperCase(),
          style: context.textTheme.labelSmall?.copyWith(
            color: LogistixColors.textSecondary,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(LogistixRadii.md),
        border: Border.all(color: status.color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.value.toUpperCase(),
        style: context.textTheme.labelMedium?.copyWith(
          color: status.color,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.content,
    required this.icon,
    this.iconColor,
    this.onIconTap,
  });

  final String title;
  final String content;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onIconTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LogistixSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LogistixRadii.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: LogistixColors.border.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (iconColor ?? LogistixColors.textTertiary).withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor ?? LogistixColors.textSecondary,
            ),
          ),
          const SizedBox(width: LogistixSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: LogistixColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: context.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: LogistixColors.text,
                  ),
                ),
              ],
            ),
          ),
          if (onIconTap != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onIconTap,
                borderRadius: BorderRadius.circular(LogistixRadii.sm),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.call_rounded,
                    size: 20,
                    color: LogistixColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BottomActionCta extends StatelessWidget {
  const _BottomActionCta({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        LogistixSpacing.lg,
        LogistixSpacing.md,
        LogistixSpacing.lg,
        LogistixSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(LogistixRadii.xl),
          topRight: Radius.circular(LogistixRadii.xl),
        ),
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          // Share tracking link
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: LogistixColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LogistixRadii.lg),
          ),
        ),
        label: const Text('Share Tracking Link'),
        icon: const Icon(Icons.share_rounded),
      ),
    );
  }
}

class _OrderDetailsShimmer extends StatelessWidget {
  const _OrderDetailsShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              const LogistixShimmer(
                height: 300,
                width: double.infinity,
                borderRadius: BorderRadius.zero,
              ),
              AppBar(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LogistixShimmer(width: 120, height: 16),
                        SizedBox(height: 8),
                        LogistixShimmer(width: 200, height: 32),
                        SizedBox(height: 12),
                        LogistixShimmer(width: 150, height: 14),
                      ],
                    ),
                    LogistixShimmer(
                      width: 100,
                      height: 36,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                const LogistixShimmer(width: 150, height: 20),
                const SizedBox(height: 20),
                LogistixShimmer(
                  width: double.infinity,
                  height: 100,
                  borderRadius: BorderRadius.circular(24),
                ),
                const SizedBox(height: 16),
                LogistixShimmer(
                  width: double.infinity,
                  height: 100,
                  borderRadius: BorderRadius.circular(24),
                ),
                const SizedBox(height: 16),
                LogistixShimmer(
                  width: double.infinity,
                  height: 100,
                  borderRadius: BorderRadius.circular(24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _showAssignRiderDialog(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Rider assignment coming soon!'),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
