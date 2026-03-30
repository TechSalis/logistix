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
              activeOrders: 0,
              unassignedOrders: 0,
              assignedOrders: 0,
              enRouteOrders: 0,
              onlineRidersCount: 0,
              busyRidersCount: 0,
            );

        return LogistixMetricsRow(
          items: [
            LogistixMetricItem(
              label: 'Total',
              value: metrics.activeOrders.toString(),
              icon: Icons.shopping_bag_rounded,
              color: Colors.blueAccent,
            ),
            LogistixMetricItem(
              label: 'Pending',
              value: metrics.unassignedOrders.toString(),
              icon: Icons.hourglass_empty_rounded,
              color: Colors.orangeAccent,
            ),
            LogistixMetricItem(
              label: 'Active',
              value: (metrics.assignedOrders + metrics.enRouteOrders).toString(),
              icon: Icons.bolt_rounded,
              color: Colors.greenAccent,
            ),
          ],
        );
      },
    );
  }
}
