import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:rider/src/features/orders/presentation/cubit/rider_metrics_cubit.dart';

class RiderMetricsCard extends StatelessWidget {
  const RiderMetricsCard({this.onRetry, super.key});
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RiderMetricsCubit, RiderMetricsState>(
      builder: (context, state) {
        if (state.error != null && state.metrics == null) {
          return BootstrapErrorView.small(
            message: state.error!,
            textColor: Colors.white70,
            iconColor: Colors.white70,
            onRetry: onRetry,
          );
        }

        final metrics = state.metrics;
        final isLoading = state.isLoading && metrics == null;

        return BootstrapMetricsRow(
          items: [
            BootstrapMetricItem(
              label: 'Total',
              value: (metrics?.totalOrders ?? 0).toString(),
              icon: Icons.shopping_bag_rounded,
              color: Colors.blueAccent,
              isLoading: isLoading,
            ),
            BootstrapMetricItem(
              label: 'Pending',
              value: (metrics?.pendingOrders ?? 0).toString(),
              icon: Icons.pending_actions_rounded,
              color: Colors.orangeAccent,
              isLoading: isLoading,
            ),
            BootstrapMetricItem(
              label: 'Done',
              value: (metrics?.deliveredOrders ?? 0).toString(),
              icon: Icons.check_circle_rounded,
              color: Colors.greenAccent,
              isLoading: isLoading,
            ),
          ],
        );
      },
    );
  }
}
