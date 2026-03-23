import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:dispatcher/src/domain/repositories/order_repository.dart';
import 'package:dispatcher/src/domain/usecases/search_riders_usecase.dart';
import 'package:dispatcher/src/features/orders/presentation/cubit/order_details_cubit.dart';
import 'package:dispatcher/src/features/riders/presentation/widgets/rider_dropdown_search.dart';
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
      create: (context) {
        return OrderDetailsCubit(context.read<OrderRepository>())
          ..loadOrder(orderId);
      },
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
      body: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const _OrderDetailsShimmer(),
            error: (message) => LogistixErrorView(message: message),
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
    final orderDetailsCubit = context.read<OrderDetailsCubit>();
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return CustomScrollView(
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
                if (order.pickupAddress?.isNotEmpty ?? false) ...[
                  LogistixInfoTile(
                    icon: Icons.trip_origin_rounded,
                    iconColor: LogistixColors.primary,
                    title: 'Pickup',
                    value: order.pickupAddress!,
                    onTap: order.hasPickupPosition
                        ? () => LauncherUtils.openMap(
                            order.pickupLat!,
                            order.pickupLng!,
                          )
                        : null,
                  ),
                  if (order.pickupPhone?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.only(left: 32),
                      child: LogistixInfoTile(
                        icon: Icons.phone_rounded,
                        iconColor: LogistixColors.primary,
                        title: 'Call Sender',
                        value: order.pickupPhone!,
                        onTap: () {
                          LauncherUtils.callNumber(order.pickupPhone!);
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
                LogistixInfoTile(
                  icon: Icons.flag_rounded,
                  iconColor: Colors.orange,
                  title: 'Drop-off',
                  value: order.dropOffAddress,
                  isBold: true,
                  onTap: order.hasDropOffPosition
                      ? () => LauncherUtils.openMap(
                          order.dropOffLat!,
                          order.dropOffLng!,
                        )
                      : null,
                ),
                if (order.dropOffPhone?.isNotEmpty ?? false)
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: LogistixInfoTile(
                      icon: Icons.phone_forwarded_rounded,
                      iconColor: Colors.orange,
                      title: 'Call Receiver',
                      value: order.dropOffPhone!,
                      onTap: () {
                        LauncherUtils.callNumber(order.dropOffPhone!);
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                LogistixInfoTile(
                  icon: Icons.payments_rounded,
                  iconColor: Colors.green,
                  title: 'COD',
                  value: order.codAmount != null && order.codAmount! > 0
                      ? '₩${order.codAmount!.toStringAsFixed(0)}'
                      : 'None',
                ),
                if (order.description != null &&
                    order.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  LogistixInfoTile(
                    icon: Icons.description_rounded,
                    iconColor: LogistixColors.textTertiary,
                    title: 'Description',
                    value: order.description!,
                  ),
                ],
                const SizedBox(height: LogistixSpacing.xl),
                _RiderSection(order: order),
                const SizedBox(height: LogistixSpacing.xl),
                Center(
                  child: LogistixButton(
                    onPressed: () => orderDetailsCubit.shareOrder(order),
                    label: 'SHARE TRACKING LINK',
                    icon: Icons.share_rounded,
                    width: 280,
                  ),
                ),
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
    final hasRiderLocation = order.rider?.hasPosition ?? false;
    final isEnRoute = order.status == OrderStatus.enRoute;

    // Show rider location when rider is assigned and order is en route
    final shouldShowRiderLocation =
        isRiderAssigned && isEnRoute && hasRiderLocation;

    final displayLocation = shouldShowRiderLocation
        ? LatLng(order.rider!.lastLat!, order.rider!.lastLng!)
        : null;

    final expandedHeight = displayLocation != null ? 260.0 : 160.0;

    return SliverAppBar(
      pinned: true,
      stretch: true,
      elevation: 0,
      expandedHeight: expandedHeight,
      backgroundColor: LogistixColors.background,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            if (displayLocation != null)
              GoogleMap(
                key: ValueKey('map_${order.id}'),
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
                      title: '${order.rider?.user?.fullName ?? ''} - En Route',
                      snippet:
                          'Delivering to '
                          '${order.dropOffAddress}',
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueOrange,
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: LogistixColors.primary.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isRiderAssigned && isEnRoute
                            ? Icons.location_searching_rounded
                            : isRiderAssigned
                            ? Icons.timer_outlined
                            : Icons.person_add_outlined,
                        size: 32,
                        color: LogistixColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      !isRiderAssigned
                          ? 'No Rider Assigned'
                          : order.status == OrderStatus.assigned
                          ? 'Waiting for Rider to Start'
                          : isEnRoute
                          ? 'Rider Location Unavailable'
                          : 'Order ${order.status.name.capitalize}',
                      style: context.textTheme.labelLarge?.bold.copyWith(
                        color: LogistixColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pickup: ${order.pickupAddress ?? 'Lagos, Nigeria'}',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
    if (order.rider == null && order.status.isCompleted) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'RIDER ASSIGNMENT'),
        const SizedBox(height: LogistixSpacing.md),
        RiderDropdownSearch(
          selectedRider: order.rider,
          searchRiders: (filter) {
            return context.read<SearchRidersUseCase>().call(filter);
          },
          onChanged: (rider) {
            if (rider != null) {
              context.read<OrderDetailsCubit>().assignRunner(rider);
            }
          },
          onUnassign: () => context.read<OrderDetailsCubit>().unassignRunner(),
          showUnassign: order.rider != null,
          isCompleted: order.status.isCompleted,
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
        status.label,
        style: context.textTheme.labelMedium?.copyWith(
          color: status.color,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}



class _BottomActionCta extends StatelessWidget {
  const _BottomActionCta({required this.order});
  final Order order;

  Widget cancelButton(BuildContext context) {
    final cubit = context.read<OrderDetailsCubit>();
    return AsyncRunnerListener(
      runner: cubit.cancelRunner,
      listener: (context, state) {
        if (state.status.isSuccess) {
          context.toast.showToast(
            'Order cancelled successfully',
            type: ToastType.success,
          );
          // Stream will auto-update via Drift
        } else if (state.status.isFailure) {
          final error = state.result?.error;
          context.toast.showToast(
            error?.message ?? 'Failed to cancel order',
            type: ToastType.error,
          );
        }
      },
      child: AsyncRunnerBuilder(
        runner: cubit.cancelRunner,
        builder: (context, state, _) {
          return LogistixButton(
            onPressed: cubit.cancelRunner.call,
            isLoading: state.status.isRunning,
            label: 'Cancel',
            type: LogistixButtonType.danger,
            icon: Icons.cancel_rounded,
          );
        },
      ),
    );
  }

  Widget markDeliveredButton(BuildContext context) {
    final cubit = context.read<OrderDetailsCubit>();
    return AsyncRunnerListener(
      runner: cubit.markDeliveredRunner,
      listener: (context, state) {
        if (state.status.isSuccess) {
          context.toast.showToast('Order delivered', type: ToastType.success);
        } else if (state.status.isFailure) {
          context.toast.showToast(
            state.result?.error.message ?? 'Failed to mark delivered',
            type: ToastType.error,
          );
        }
      },
      child: AsyncRunnerBuilder(
        runner: cubit.markDeliveredRunner,
        builder: (context, state, _) {
          return LogistixButton(
            onPressed: cubit.markDeliveredRunner.call,
            isLoading: state.status.isRunning,
            label: 'Mark Delivered',
            icon: Icons.check_circle_rounded,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget? actionButton;
    switch (order.status) {
      case OrderStatus.unassigned:
        actionButton = cancelButton(context);
      case OrderStatus.assigned:
      case OrderStatus.enRoute:
        actionButton = Row(
          children: [
            Expanded(flex: 2, child: cancelButton(context)),
            const SizedBox(width: 12),
            Expanded(flex: 3, child: markDeliveredButton(context)),
          ],
        );
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        actionButton = null;
    }

    if (actionButton == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LogistixSpacing.lg,
        vertical: LogistixSpacing.md,
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
      child: actionButton,
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
