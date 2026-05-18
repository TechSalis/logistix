import 'package:dispatcher/src/features/deliveries/data/dtos/dispatcher_metrics_dto.dart';
import 'package:dispatcher/src/features/deliveries/presentation/cubit/metrics_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DeliverySummaryCard extends StatelessWidget {
  const DeliverySummaryCard({this.onRetry, super.key});

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
              activeDeliveries: 0,
              unassignedDeliveries: 0,
              assignedDeliveries: 0,
              enRouteDeliveries: 0,
              onlineRidersCount: 0,
              busyRidersCount: 0,
            );

        return BootstrapMetricsRow(
          items: [
            BootstrapMetricItem(
              label: 'Total',
              value: metrics.activeDeliveries.toString(),
              icon: LucideIcons.shoppingBag,
              color: Colors.blueAccent,
            ),
            BootstrapMetricItem(
              label: 'Pending',
              value: metrics.unassignedDeliveries.toString(),
              icon: LucideIcons.timer,
              color: Colors.orangeAccent,
            ),
            BootstrapMetricItem(
              label: 'Active',
              value: ((metrics.assignedDeliveries ?? 0) + (metrics.enRouteDeliveries ?? 0)).toString(),
              icon: LucideIcons.zap,
              color: Colors.greenAccent,
            ),
          ],
        );
      },
    );
  }
}
