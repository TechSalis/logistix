import 'package:dispatcher/src/features/orders/data/dtos/dispatcher_metrics_dto.dart';
import 'package:dispatcher/src/features/orders/presentation/cubit/metrics_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistix_ux/logistix_ux.dart';

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({this.onRetry, super.key});

  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetricsCubit, MetricsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: BootstrapInlineLoader());
        }
        if (state.error != null) {
          return BootstrapErrorView.small(
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

        return BootstrapMetricsRow(
          items: [
            BootstrapMetricItem(
              label: 'Total',
              value: metrics.activeOrders.toString(),
              icon: Icons.shopping_bag_rounded,
              color: Colors.blueAccent,
            ),
            BootstrapMetricItem(
              label: 'Pending',
              value: metrics.unassignedOrders.toString(),
              icon: Icons.hourglass_empty_rounded,
              color: Colors.orangeAccent,
            ),
            BootstrapMetricItem(
              label: 'Active',
              value: ((metrics.assignedOrders ?? 0) + (metrics.enRouteOrders ?? 0)).toString(),
              icon: Icons.bolt_rounded,
              color: Colors.greenAccent,
            ),
          ],
        );
      },
    );
  }
}
