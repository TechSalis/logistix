import 'package:bootstrap/extensions/string_extension.dart';
import 'package:dispatcher/src/features/riders/presentation/cubit/riders_cubit.dart';
import 'package:dispatcher/src/features/riders/presentation/utils/rider_map_utils.dart';
import 'package:dispatcher/src/presentation/router/dispatcher_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class RiderCard extends StatelessWidget {
  const RiderCard({required this.rider, required this.isPending, super.key});
  final Rider rider;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final statusColor = rider.status.color;
    final activeOrder = rider.activeOrder;
    final riderColor = RiderMapUtils.getColor(rider.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => context.push(DispatcherRoutes.riderDetails(rider.id)),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    LogistixAvatar(
                      name: rider.fullName,
                      statusColor: statusColor,
                      backgroundColor: riderColor.withValues(alpha: 0.1),
                      foregroundColor: riderColor,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rider.fullName,
                            style: context.textTheme.titleMedium?.bold.copyWith(
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  rider.status.value.capitalizeFirst(),
                                  style: context.textTheme.labelSmall?.bold.copyWith(
                                    color: statusColor,
                                    letterSpacing: 0.5,
                                    fontSize: 10,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (rider.phoneNumber != null) ...[
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '  •  ${rider.phoneNumber}',
                                    style: context.textTheme.labelSmall?.copyWith(
                                      color: LogistixColors.textTertiary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isPending)
                      BlocBuilder<RidersCubit, RidersState>(
                        builder: (context, state) {
                          final isAccepting =
                              state.acceptingRiderIds.contains(rider.id);
                          final isRejecting =
                              state.rejectingRiderIds.contains(rider.id);
                          final isProcessing = isAccepting || isRejecting;

                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ActionButton(
                                icon: Icons.check_rounded,
                                color: LogistixColors.success,
                                isLoading: isAccepting,
                                onPressed: isProcessing
                                    ? null
                                    : () => context
                                        .read<RidersCubit>()
                                        .acceptRider(rider.id),
                              ),
                              const SizedBox(width: 8),
                              _ActionButton(
                                icon: Icons.close_rounded,
                                color: LogistixColors.error,
                                isLoading: isRejecting,
                                onPressed: isProcessing
                                    ? null
                                    : () => context
                                        .read<RidersCubit>()
                                        .rejectRider(rider.id),
                              ),
                            ],
                          );
                        },
                      )
                    else ...[
                      if (rider.hasLocation)
                        _ActionButton(
                          icon: Icons.location_on_rounded,
                          color: riderColor,
                          onPressed: () => context.go(
                            DispatcherRoutes.ridersMap,
                            extra: rider.id,
                          ),
                        ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: LogistixColors.textTertiary.withValues(alpha: 0.5),
                      ),
                    ],
                  ],
                ),
                if (activeOrder != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          LogistixColors.primary.withValues(alpha: 0.06),
                          LogistixColors.primary.withValues(alpha: 0.02),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: LogistixColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: LogistixColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.local_shipping_rounded,
                            size: 18,
                            color: LogistixColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      'ACTIVE ORDER',
                                      style: context.textTheme.labelSmall?.bold.copyWith(
                                        color: LogistixColors.textTertiary,
                                        letterSpacing: 0.5,
                                        fontSize: 10,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: LogistixColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      activeOrder.status.label,
                                      style: context.textTheme.labelSmall?.bold.copyWith(
                                        color: LogistixColors.primary,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                activeOrder.dropOffAddress,
                                style: context.textTheme.bodySmall?.bold,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isLoading = false,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AnimatedScaleTap(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              )
            : Icon(icon, color: color, size: 20),
      ),
    );
  }
}
