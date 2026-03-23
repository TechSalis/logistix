import 'package:dispatcher/src/features/orders/presentation/cubit/metrics_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({this.onRetry, super.key});

  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
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
            const DispatcherMetricsDto(
              totalOrders: 0,
              pendingOrders: 0,
              deliveredOrders: 0,
              totalRiders: 0,
              activeRiders: 0,
              availableRiders: 0,
            );

        return LogistixMetricsRow(
          items: [
            LogistixMetricItem(
              label: 'Total',
              value: metrics.totalOrders.toString(),
              icon: Icons.shopping_bag_rounded,
              color: Colors.blueAccent,
            ),
            LogistixMetricItem(
              label: 'Pending',
              value: metrics.pendingOrders.toString(),
              icon: Icons.hourglass_empty_rounded,
              color: Colors.orangeAccent,
            ),
            LogistixMetricItem(
              label: 'Done',
              value: metrics.deliveredOrders.toString(),
              icon: Icons.check_circle_rounded,
              color: Colors.greenAccent,
            ),
          ],
        );
      },
    );
  }
}
