import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:collection/collection.dart';

import 'package:dispatcher/src/features/riders/presentation/cubit/riders_cubit.dart';
import 'package:dispatcher/src/presentation/router/dispatcher_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class RiderDetailsPage extends StatelessWidget {
  const RiderDetailsPage({required this.riderId, super.key});
  final String riderId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RidersCubit, RidersState>(
      builder: (context, state) {
        final riders = [...state.riders, ...state.pendingRiders];
        final rider = riders.firstWhereOrNull((r) => r.id == riderId);

        if (rider == null) {
          return const Scaffold(
            backgroundColor: LogistixColors.background,
            body: Center(child: BootstrapLoadingIndicator()),
          );
        }

        final hasLocation = rider.hasLocation;
        return Scaffold(
          backgroundColor: LogistixColors.background,
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: LogistixColors.text),
            title: Text(
              'Rider Details',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              if (rider.permitStatus != PermitStatus.APPROVED)
                Padding(
                  padding: const EdgeInsets.only(right: BootstrapSpacing.md),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: BootstrapSpacing.sm,
                        vertical: BootstrapSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: LogistixColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(BootstrapRadii.lg),
                        border: Border.all(
                          color: LogistixColors.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        rider.permitStatus == PermitStatus.REJECTED ? 'Rejected' : 'Pending',
                        style: context.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: rider.permitStatus == PermitStatus.REJECTED ? LogistixColors.error : LogistixColors.warning,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: BootstrapSpacing.lg,
              vertical: BootstrapSpacing.xs,
            ),
            child: BootstrapEntrance(
              children: [
                _RiderProfileHeader(rider: rider),
                const SizedBox(height: BootstrapSpacing.xl),
                if (rider.phoneNumber != null &&
                    rider.phoneNumber!.isNotEmpty)
                  _QuickActionsRow(rider: rider),
                const SizedBox(height: BootstrapSpacing.xl),
                BootstrapButton(
                  onPressed: hasLocation
                      ? () {
                          context.go(
                            DispatcherRoutes.ridersMap,
                            extra: rider.id,
                          );
                        }
                      : null,
                  label: hasLocation ? 'View on Map' : 'Location Unavailable',
                  icon: Icons.map_rounded,
                ),
                const SizedBox(height: BootstrapSpacing.xl),
                const _SectionTitle(title: 'Contact Information'),
                const SizedBox(height: BootstrapSpacing.sm),
                _ContactCard(rider: rider),
                if (rider.permitStatus == PermitStatus.PENDING) ...[
                  const SizedBox(height: BootstrapSpacing.xxl),
                  _ApprovalActions(rider: rider),
                ],
                const SizedBox(height: BootstrapSpacing.xl),
                _ActiveOrdersSection(riderId: rider.id),
                const SizedBox(height: BootstrapSpacing.xxxl),
              ],
            ),
          ),
        );
      },
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
      style: context.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: LogistixColors.textTertiary,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _RiderProfileHeader extends StatelessWidget {
  const _RiderProfileHeader({required this.rider});
  final Rider rider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BootstrapAvatar(
          name: rider.fullName,
          size: 100,
          statusColor: rider.status.color,
          useGradient: true,
        ),
        const SizedBox(height: BootstrapSpacing.lg),
        Text(
          rider.fullName,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: BootstrapSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ProminentStatusBadge(status: rider.status),
            if (rider.batteryLevel != null) ...[
              const SizedBox(width: BootstrapSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BootstrapSpacing.sm,
                  vertical: BootstrapSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: LogistixColors.surfaceDim,
                  borderRadius: BorderRadius.circular(BootstrapRadii.lg),
                  border: Border.all(
                    color: LogistixColors.border.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      rider.batteryLevel! > 20
                          ? Icons.battery_charging_full_rounded
                          : Icons.battery_alert_rounded,
                      size: 14,
                      color: rider.batteryLevel! > 20
                          ? LogistixColors.success
                          : LogistixColors.error,
                    ),
                    const SizedBox(width: BootstrapSpacing.xs),
                    Text(
                      '${rider.batteryLevel}%',
                      style: context.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: LogistixColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _ProminentStatusBadge extends StatelessWidget {
  const _ProminentStatusBadge({required this.status});
  final RiderStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    IconData icon;
    switch (status) {
      case RiderStatus.ONLINE:
        icon = Icons.check_circle_rounded;
      case RiderStatus.BUSY:
        icon = Icons.time_to_leave_rounded;
      case RiderStatus.OFFLINE:
        icon = Icons.power_settings_new_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BootstrapSpacing.md,
        vertical: BootstrapSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(BootstrapRadii.xl),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: BootstrapSpacing.xs),
          Text(
            status.name,
            style: context.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.rider});
  final Rider rider;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.phone_rounded,
            label: 'Voice Call',
            color: LogistixColors.primary,
            onPressed: () {
              context.read<RidersCubit>().callRunner(rider.phoneNumber);
            },
          ),
        ),
        const SizedBox(width: BootstrapSpacing.md),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.chat_bubble_rounded,
            label: 'WhatsApp',
            color: const Color(0xFF25D366),
            onPressed: () {
              context.read<RidersCubit>().whatsappRunner(
                rider.phoneNumber,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedScaleTap(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(BootstrapRadii.xl),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        padding: const EdgeInsets.symmetric(vertical: BootstrapSpacing.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: BootstrapSpacing.sm),
            Text(
              label,
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.rider});

  final Rider rider;

  @override
  Widget build(BuildContext context) {
    return BootstrapSettingsCard(
      children: [
        BootstrapSettingsTile(
          icon: Icons.phone_rounded,
          title: 'Phone Number',
          subtitle: rider.phoneNumber ?? 'Not provided',
        ),
        BootstrapSettingsTile(
          icon: Icons.email_rounded,
          title: 'Email Address',
          subtitle: rider.email,
        ),
      ],
    );
  }
}

class _ApprovalActions extends StatelessWidget {
  const _ApprovalActions({required this.rider});
  final Rider rider;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RidersCubit, RidersState>(
      listener: (context, state) {
        if (state.error != null) {
          context.toast.showToast(state.error!, type: ToastType.error);
        }
      },
      builder: (context, state) {
        final isAccepting = state.acceptingRiderIds.contains(rider.id);
        final isRejecting = state.rejectingRiderIds.contains(rider.id);
        final isAnyProcessing = isAccepting || isRejecting;

        return Row(
          children: [
            Expanded(
              child: BootstrapButton(
                onPressed: isAnyProcessing
                    ? null
                    : () => context.read<RidersCubit>().rejectRider(rider.id),
                label: 'Reject',
                type: BootstrapButtonType.outline,
                isLoading: isRejecting,
              ),
            ),
            const SizedBox(width: BootstrapSpacing.md),
            Expanded(
              child: BootstrapButton(
                onPressed: isAnyProcessing
                    ? null
                    : () => context.read<RidersCubit>().acceptRider(rider.id),
                label: 'Accept Rider',
                isLoading: isAccepting,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ActiveOrdersSection extends StatelessWidget {
  const _ActiveOrdersSection({required this.riderId});
  final String riderId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Order>>(
      stream: context.read<OrderDao>().watchOrders(
        riderId: riderId,
        statuses: [OrderStatus.ASSIGNED, OrderStatus.EN_ROUTE],
        limit: 3,
      ),
      builder: (context, snapshot) {
        final orders = snapshot.data ?? [];

        if (snapshot.connectionState == ConnectionState.waiting &&
            orders.isEmpty) {
          return const Center(child: BootstrapInlineLoader());
        }

        if (orders.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _SectionTitle(title: 'Active Orders'),
                BootstrapButton(
                  type: BootstrapButtonType.text,
                  onPressed: () {
                    context.go(DispatcherRoutes.orders);
                  },
                  label: 'View All',
                ),
              ],
            ),
            const SizedBox(height: BootstrapSpacing.sm),
            ...orders.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: BootstrapSpacing.md),
                child: OrderPreviewCard(
                  order: order,
                  onTap: () =>
                      context.push(DispatcherRoutes.orderDetails(order.id)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
