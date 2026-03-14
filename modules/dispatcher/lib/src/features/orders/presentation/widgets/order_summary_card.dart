import 'package:dispatcher/src/features/orders/presentation/cubit/metrics_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({required this.onRetry, super.key});

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

    return BlocBuilder<MetricsCubit, MetricsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: LogistixInlineLoader());
        }
        if (state.error != null) {
          return LogistixErrorView.small(
            message: state.error!,
            iconColor: LogistixColors.neutral100,
            textColor: LogistixColors.textOnPrimary,
            onRetry: onRetry,
          );
        }

        final metrics =
            state.metrics ??
            const Metrics(
              totalOrders: 0,
              pendingOrders: 0,
              inProgressOrders: 0,
              deliveredOrders: 0,
              onlineRiders: 0,
              codExpectedToday: 0,
            );

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
                'Pending',
                metrics.pendingOrders.toString(),
                Icons.hourglass_empty_rounded,
                Colors.orangeAccent,
              ),
              const SizedBox(width: 12),
              metric(
                'Active',
                metrics.inProgressOrders.toString(),
                Icons.rocket_launch_rounded,
                Colors.purpleAccent,
              ),
              const SizedBox(width: 12),
              metric(
                'Done',
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
