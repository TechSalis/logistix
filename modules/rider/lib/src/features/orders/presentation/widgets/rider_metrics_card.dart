import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:rider/src/features/orders/presentation/cubit/rider_orders_cubit.dart';
import 'package:shared/shared.dart';

class RiderMetricsCard extends StatelessWidget {
  const RiderMetricsCard({required this.onRetry, super.key});
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    Widget metric(String label, String value, IconData icon, Color color) =>
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: context.textTheme.headlineSmall?.bold.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: context.textTheme.labelMedium?.bold.copyWith(
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );

    return BlocBuilder<RiderOrdersCubit, RiderOrdersState>(
      builder: (context, state) {
        if (state.isLoadingMetrics) {
          return const Center(child: LogistixInlineLoader());
        }

        if (state.error != null && state.metrics == null) {
          return LogistixErrorView.small(
            message: state.error!,
            iconColor: LogistixColors.neutral100,
            textColor: LogistixColors.textOnPrimary,
            onRetry: onRetry,
          );
        }

        final metrics =
            state.metrics ??
            const RiderMetrics(
              totalOrders: 0,
              pendingOrders: 0,
              inProgressOrders: 0,
              deliveredOrders: 0,
              codExpectedToday: 0.0,
              onlineRiders: 0,
            );

        final assignedOrders = metrics.pendingOrders + metrics.inProgressOrders;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              metric(
                'Total',
                metrics.totalOrders.toString(),
                Icons.shopping_bag_rounded,
                Colors.blueAccent,
              ),
              const SizedBox(width: 12),
              metric(
                'Assigned',
                assignedOrders.toString(),
                Icons.assignment_rounded,
                Colors.orangeAccent,
              ),
              const SizedBox(width: 12),
              metric(
                'Delivered',
                metrics.deliveredOrders.toString(),
                Icons.check_circle_rounded,
                Colors.greenAccent,
              ),
            ],
          ),
        );
      },
    );
  }
}
