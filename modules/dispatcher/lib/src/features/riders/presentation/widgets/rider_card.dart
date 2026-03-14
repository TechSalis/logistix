import 'package:bootstrap/extensions/string_extension.dart';

import 'package:dispatcher/src/features/riders/presentation/cubit/riders_cubit.dart';
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LogistixColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => context.push(DispatcherRoutes.riderDetails(rider.id)),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                LogistixColors.primary.withValues(alpha: 0.1),
                                LogistixColors.primary.withValues(alpha: 0.05),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            rider.fullName.characters.firstOrNull
                                    ?.toUpperCase() ??
                                '',
                            style: context.textTheme.titleMedium?.bold.copyWith(
                              color: LogistixColors.primary,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rider.fullName,
                            style: context.textTheme.titleMedium?.bold,
                          ),
                          const SizedBox(height: 2),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: rider.status.value.capitalizeFirst(),
                                ),
                                if (rider.phoneNumber != null) ...[
                                  const TextSpan(
                                    text: ' • ',
                                    style: TextStyle(
                                      color: LogistixColors.textTertiary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: rider.phoneNumber,
                                    style: context.textTheme.labelMedium
                                        ?.copyWith(
                                          color: LogistixColors.textSecondary,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                            style: context.textTheme.labelMedium?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isPending)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.check_circle_rounded,
                              color: LogistixColors.success,
                            ),
                            onPressed: () => context
                                .read<RidersCubit>()
                                .acceptRider(rider.id),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.cancel_rounded,
                              color: LogistixColors.error,
                            ),
                            onPressed: () => context
                                .read<RidersCubit>()
                                .rejectRider(rider.id),
                          ),
                        ],
                      )
                    else
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: LogistixColors.textTertiary,
                      ),
                  ],
                ),
                if (activeOrder != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: LogistixColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.local_shipping_outlined,
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
                                  Text(
                                    'Active Order',
                                    style: context.textTheme.labelSmall?.bold
                                        .copyWith(
                                          color: LogistixColors.textTertiary,
                                        ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    activeOrder.status.value,
                                    style: context.textTheme.labelSmall?.bold
                                        .copyWith(
                                          color: LogistixColors.primary,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                activeOrder.pickupAddress,
                                style: context.textTheme.bodySmall?.semiBold,
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

class RiderInfoListTile extends StatelessWidget {
  const RiderInfoListTile({
    required this.rider,
    required this.enabled,
    required this.isSelected,
    super.key,
  });

  final Rider rider;
  final bool enabled;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: enabled,
      leading: CircleAvatar(
        backgroundColor: LogistixColors.primary.withValues(alpha: 0.1),
        child: Text(
          rider.fullName.isNotEmpty ? rider.fullName[0].toUpperCase() : '?',
          style: const TextStyle(
            color: LogistixColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        rider.fullName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      selected: isSelected,
    );
  }
}
