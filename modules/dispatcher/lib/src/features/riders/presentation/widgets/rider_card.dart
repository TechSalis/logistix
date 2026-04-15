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
    final riderColor = RiderMapUtils.getColor(rider.id);

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: BootstrapSpacing.md,
          vertical: BootstrapSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(BootstrapRadii.card),
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
          borderRadius: BorderRadius.circular(BootstrapRadii.card),
          child: InkWell(
            onTap: () => context.push(DispatcherRoutes.riderDetails(rider.id)),
            borderRadius: BorderRadius.circular(BootstrapRadii.card),
            child: Padding(
              padding: const EdgeInsets.all(BootstrapSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      BootstrapAvatar(
                        name: rider.fullName,
                        statusColor: statusColor,
                        backgroundColor: riderColor.withValues(alpha: 0.1),
                        foregroundColor: riderColor,
                      ),
                      const SizedBox(width: BootstrapSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rider.fullName,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: BootstrapSpacing.xxs),
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
                                const SizedBox(width: BootstrapSpacing.xs),
                                Flexible(
                                  child: Text(
                                    rider.status.label,
                                    style: context.textTheme.labelSmall?.bold
                                        .copyWith(
                                          color: statusColor,
                                          letterSpacing: 0.5,
                                          fontSize: 10,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (rider.phoneNumber != null) ...[
                                  const SizedBox(width: BootstrapSpacing.xs),
                                  Expanded(
                                    child: Text(
                                      '  •  ${rider.phoneNumber}',
                                      style: context.textTheme.labelSmall
                                          ?.copyWith(
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
                            final isAccepting = state.acceptingRiderIds
                                .contains(rider.id);
                            final isRejecting = state.rejectingRiderIds
                                .contains(rider.id);
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
                                const SizedBox(width: BootstrapSpacing.xs),
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
                        const SizedBox(width: BootstrapSpacing.xxs),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: LogistixColors.textTertiary.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
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
        padding: const EdgeInsets.all(BootstrapSpacing.xs),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(BootstrapRadii.lg),
        ),
        child: isLoading
            ? const Center(child: BootstrapInlineLoader(size: 14))
            : Icon(icon, color: color, size: 20),
      ),
    );
  }
}
