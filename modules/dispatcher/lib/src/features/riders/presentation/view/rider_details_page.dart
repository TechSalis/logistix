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

        final hasLocation = rider.hasLocation;

        return Scaffold(
          backgroundColor: LogistixColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: LogistixColors.text),
            title: Text(rider.fullName),
            actions: [
              if (!rider.isAccepted)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: LogistixColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: LogistixColors.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'PENDING',
                        style: context.textTheme.labelMedium?.bold.copyWith(
                          color: LogistixColors.warning,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _RiderProfileHeader(rider: rider),
                const SizedBox(height: 24),
                if (rider.phoneNumber != null && rider.phoneNumber!.isNotEmpty)
                  _QuickActionsRow(rider: rider),
                const SizedBox(height: 32),
                SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: hasLocation ? () => context.pop(rider) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LogistixColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: LogistixColors.border,
                      disabledForegroundColor: LogistixColors.textTertiary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.map_rounded),
                    label: Text(
                      hasLocation ? 'View on Map' : 'Location Unavailable',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (rider.activeOrder != null) ...[
                  const SizedBox(height: 32),
                  const _SectionTitle(title: 'Current Delivery'),
                  const SizedBox(height: 16),
                  _ClickableOrderCard(order: rider.activeOrder!),
                ],
                const SizedBox(height: 32),
                const _SectionTitle(title: 'Contact Information'),
                const SizedBox(height: 16),
                _ContactCard(rider: rider),
                if (!rider.isAccepted) ...[
                  const SizedBox(height: 48),
                  _ApprovalActions(rider: rider),
                ],
                const SizedBox(height: 100),
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
      title.toUpperCase(),
      style: context.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w900,
        color: LogistixColors.textTertiary,
        letterSpacing: 1,
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
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: LogistixColors.primary.withValues(alpha: 0.1),
            border: Border.all(
              color: LogistixColors.primary.withValues(alpha: 0.2),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: LogistixColors.primary.withValues(alpha: 0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              rider.fullName.isNotEmpty ? rider.fullName[0].toUpperCase() : '?',
              style: context.textTheme.displaySmall?.bold.copyWith(
                color: LogistixColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ProminentStatusBadge(status: rider.status),
            if (rider.batteryLevel != null) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: LogistixColors.surfaceDim,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: LogistixColors.border),
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
                    const SizedBox(width: 4),
                    Text(
                      '${rider.batteryLevel}%',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: LogistixColors.textSecondary,
                        fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            status.name.toUpperCase(),
            style: context.textTheme.labelMedium?.bold.copyWith(
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
            label: 'Call',
            color: LogistixColors.primary,
            onPressed: () {
              context.read<RidersCubit>().callRunner.call(rider.phoneNumber);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.chat_bubble_rounded,
            label: 'WhatsApp',
            color: const Color(0xFF25D366),
            onPressed: () {
              context.read<RidersCubit>().whatsappRunner(rider.phoneNumber);
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
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: context.textTheme.titleSmall?.bold.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: LogistixColors.primary.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: LogistixColors.primary.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: LogistixColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.outbox_rounded,
                color: LogistixColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.trackingNumber}',
                    style: context.textTheme.titleMedium?.bold,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: order.status.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order.status.value,
                          style: context.textTheme.labelSmall?.bold.copyWith(
                            color: order.status.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.pickupAddress,
                          style: context.textTheme.bodySmall?.copyWith(
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
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: LogistixColors.surfaceDim,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: LogistixColors.textTertiary,
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: LogistixColors.border.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            icon: Icons.phone_outlined,
            title: 'Phone',
            value: rider.phoneNumber ?? 'Not provided',
          ),
          const Divider(height: 32, indent: 40),
          _InfoRow(
            icon: Icons.email_outlined,
            title: 'Email',
            value: rider.email,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: LogistixColors.background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, size: 20, color: LogistixColors.textSecondary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.labelMedium?.copyWith(
                  color: LogistixColors.textTertiary,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: context.textTheme.bodyMedium?.semiBold),
            ],
          ),
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
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.read<RidersCubit>().rejectRider(rider.id),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              side: const BorderSide(color: LogistixColors.error),
              foregroundColor: LogistixColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Reject Rider',
              style: context.textTheme.titleSmall?.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => context.read<RidersCubit>().acceptRider(rider.id),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor: LogistixColors.success,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Accept Rider',
              style: context.textTheme.titleSmall?.bold,
            ),
          ),
        ),
      ],
    );
  }
}
