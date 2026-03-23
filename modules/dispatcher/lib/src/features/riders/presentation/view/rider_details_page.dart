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
        final rider = [
          ...state.riders,
          ...state.pendingRiders,
        ].firstWhereOrNull((r) => r.id == riderId);

        if (rider == null) {
          return const Scaffold(
            backgroundColor: LogistixColors.background,
            body: Center(child: LogistixLoadingIndicator()),
          );
        }

        final hasLocation = rider.hasPosition;
        return Scaffold(
          backgroundColor: LogistixColors.background,
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: LogistixColors.text),
            title: Text(
              'Rider Details',
              style: context.textTheme.titleMedium?.bold,
            ),
            actions: [
              if (!rider.isAccepted)
                Padding(
                  padding: const EdgeInsets.only(right: LogistixSpacing.md),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: LogistixSpacing.sm,
                        vertical: LogistixSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: LogistixColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: LogistixColors.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'PENDING',
                        style: context.textTheme.labelSmall?.bold.copyWith(
                          color: LogistixColors.warning,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: LogistixSpacing.lg,
              vertical: LogistixSpacing.xs,
            ),
            child: LogistixEntrance(
              children: [
                _RiderProfileHeader(rider: rider),
                const SizedBox(height: LogistixSpacing.xl),
                if (rider.user?.phoneNumber != null &&
                    rider.user!.phoneNumber!.isNotEmpty)
                  _QuickActionsRow(rider: rider),
                const SizedBox(height: LogistixSpacing.xl),
                LogistixButton(
                  onPressed: hasLocation
                      ? () {
                          context.go(
                            DispatcherRoutes.ridersMap,
                            extra: rider.id,
                          );
                        }
                      : null,
                  label: hasLocation ? 'VIEW ON MAP' : 'LOCATION UNAVAILABLE',
                  icon: Icons.map_rounded,
                ),
                if (rider.activeOrder != null) ...[
                  const SizedBox(height: LogistixSpacing.xl),
                  const _SectionTitle(title: 'CURRENT DELIVERY'),
                  const SizedBox(height: LogistixSpacing.sm),
                  _ClickableOrderCard(order: rider.activeOrder!),
                ],
                const SizedBox(height: LogistixSpacing.xl),
                const _SectionTitle(title: 'CONTACT INFORMATION'),
                const SizedBox(height: LogistixSpacing.sm),
                _ContactCard(rider: rider),
                if (!rider.isAccepted) ...[
                  const SizedBox(height: LogistixSpacing.xxl),
                  _ApprovalActions(rider: rider),
                ],
                const SizedBox(height: LogistixSpacing.xxxl),
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
      style: context.textTheme.labelSmall?.bold.copyWith(
        color: LogistixColors.textTertiary,
        letterSpacing: 1.2,
        fontSize: 11,
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
        LogistixAvatar(
          name: rider.user?.fullName,
          size: 100,
          statusColor: rider.status.color,
          useGradient: true,
        ),
        const SizedBox(height: LogistixSpacing.lg),
        Text(
          rider.user?.fullName ?? '',
          style: context.textTheme.headlineSmall?.bold,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: LogistixSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ProminentStatusBadge(status: rider.status),
            if (rider.batteryLevel != null) ...[
              const SizedBox(width: LogistixSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: LogistixSpacing.sm,
                  vertical: LogistixSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: LogistixColors.surfaceDim,
                  borderRadius: BorderRadius.circular(12),
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
                    const SizedBox(width: LogistixSpacing.xs),
                    Text(
                      '${rider.batteryLevel}%',
                      style: context.textTheme.labelSmall?.bold.copyWith(
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
      case RiderStatus.online:
        icon = Icons.check_circle_rounded;
      case RiderStatus.busy:
        icon = Icons.time_to_leave_rounded;
      case RiderStatus.offline:
        icon = Icons.power_settings_new_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LogistixSpacing.md,
        vertical: LogistixSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: LogistixSpacing.xs),
          Text(
            status.name.toUpperCase(),
            style: context.textTheme.labelSmall?.bold.copyWith(
              color: color,
              letterSpacing: 0.5,
              fontSize: 10,
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
              context.read<RidersCubit>().callRunner(rider.user?.phoneNumber);
            },
          ),
        ),
        const SizedBox(width: LogistixSpacing.md),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.chat_bubble_rounded,
            label: 'WhatsApp',
            color: const Color(0xFF25D366),
            onPressed: () {
              context.read<RidersCubit>().whatsappRunner(
                rider.user?.phoneNumber,
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        padding: const EdgeInsets.symmetric(vertical: LogistixSpacing.md),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: LogistixSpacing.xs),
            Text(
              label,
              style: context.textTheme.labelMedium?.bold.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClickableOrderCard extends StatelessWidget {
  const _ClickableOrderCard({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return AnimatedScaleTap(
      onTap: () => context.push(DispatcherRoutes.orderDetails(order.id)),
      child: Container(
        padding: const EdgeInsets.all(LogistixSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: LogistixColors.primary.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(LogistixSpacing.sm),
              decoration: BoxDecoration(
                color: LogistixColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.local_shipping_rounded,
                color: LogistixColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: LogistixSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.trackingNumber}',
                    style: context.textTheme.titleMedium?.bold,
                  ),
                  const SizedBox(height: LogistixSpacing.xxs),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: LogistixSpacing.xs,
                          vertical: LogistixSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: order.status.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order.status.label.toUpperCase(),
                          style: context.textTheme.labelSmall?.bold.copyWith(
                            color: order.status.color,
                            fontSize: 9,
                          ),
                        ),
                      ),
                      const SizedBox(width: LogistixSpacing.xs),
                      Expanded(
                        child: Text(
                          order.dropOffAddress,
                          style: context.textTheme.bodySmall?.semiBold.copyWith(
                            color: LogistixColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: LogistixSpacing.sm),
            Icon(
              Icons.chevron_right_rounded,
              color: LogistixColors.textTertiary.withValues(alpha: 0.5),
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
    return LogistixSettingsCard(
      children: [
        LogistixSettingsTile(
          icon: Icons.phone_rounded,
          title: 'Phone Number',
          subtitle: rider.user?.phoneNumber ?? 'Not provided',
        ),
        LogistixSettingsTile(
          icon: Icons.email_rounded,
          title: 'Email Address',
          subtitle: rider.user?.email ?? 'Not provided',
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
              child: LogistixButton(
                onPressed: isAnyProcessing
                    ? null
                    : () => context.read<RidersCubit>().rejectRider(rider.id),
                label: 'REJECT',
                type: LogistixButtonType.outline,
                isLoading: isRejecting,
              ),
            ),
            const SizedBox(width: LogistixSpacing.md),
            Expanded(
              child: LogistixButton(
                onPressed: isAnyProcessing
                    ? null
                    : () => context.read<RidersCubit>().acceptRider(rider.id),
                label: 'ACCEPT RIDER',
                isLoading: isAccepting,
              ),
            ),
          ],
        );
      },
    );
  }
}
