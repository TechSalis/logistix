import 'package:dispatcher/src/features/orders/presentation/cubit/metrics_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class RiderSummaryCard extends StatelessWidget {
  const RiderSummaryCard({this.onRetry, super.key});

  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetricsCubit, MetricsState>(
      builder: (context, state) {
        if (state.isLoading && state.metrics == null) {
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
              value: metrics.totalRiders.toString(),
              icon: Icons.people_alt_rounded,
              color: Colors.blueAccent[100]!,
            ),
            LogistixMetricItem(
              label: 'Active',
              value: metrics.activeRiders.toString(),
              icon: Icons.bolt_rounded,
              color: Colors.greenAccent[200]!,
            ),
            LogistixMetricItem(
              label: 'Available',
              value: metrics.availableRiders.toString(),
              icon: Icons.check_circle_rounded,
              color: Colors.orangeAccent[100]!,
            ),
          ],
        );
      },
    );
  }
}
