import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:rider/src/domain/repositories/rider_repository.dart';
import 'package:rider/src/presentation/cubit/rider_order_details_cubit.dart';
import 'package:shared/shared.dart';

class RiderOrderDetailsPage extends StatelessWidget {
  const RiderOrderDetailsPage({
    required this.orderId,
    this.initialOrder,
    super.key,
  });

  final String orderId;
  final Order? initialOrder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return RiderOrderDetailsCubit(context.read<RiderRepository>())
          ..loadOrder(orderId, initialOrder: initialOrder);
      },
      child: _RiderOrderDetailsView(orderId),
    );
  }
}

class _RiderOrderDetailsView extends StatelessWidget {
  const _RiderOrderDetailsView(this.orderId);

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LogistixColors.background,
      body: BlocConsumer<RiderOrderDetailsCubit, RiderOrderDetailsState>(
        listener: (context, state) {
          state.whenOrNull(
            error: (message) {
              context.toast.showToast(message, type: ToastType.error);
            },
          );
        },
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const _OrderDetailsShimmer(),
            error: (message) => LogistixErrorView(message: message),
            loaded: (order) => _OrderLoadedContent(order: order),
          );
        },
      ),
      bottomNavigationBar:
          BlocBuilder<RiderOrderDetailsCubit, RiderOrderDetailsState>(
            builder: (context, state) {
              return state.maybeWhen(
                loaded: (order) => _BottomActionCta(order: order),
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
    );
  }
}

class _OrderLoadedContent extends StatelessWidget {
  const _OrderLoadedContent({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverAppBar(title: Text('Order Details')),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              LogistixSpacing.lg,
              LogistixSpacing.xl,
              LogistixSpacing.lg,
              LogistixSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OrderHeader(order: order, dateFormat: dateFormat),
                const SizedBox(height: LogistixSpacing.xl),
                const _SectionTitle(title: 'DELIVERY DETAILS'),
                const SizedBox(height: LogistixSpacing.md),
                if (order.pickupAddress?.isNotEmpty ?? false) ...[
                  LogistixInfoTile(
                    icon: Icons.trip_origin_rounded,
                    iconColor: LogistixColors.primary,
                    title: 'Pickup',
                    value: order.pickupAddress!,
                    onTap: order.hasPickupPosition
                        ? () => LauncherUtils.openMap(
                              order.pickupLat!,
                              order.pickupLng!,
                            )
                        : null,
                  ),
                  if (order.pickupPhone?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.only(left: 32),
                      child: LogistixInfoTile(
                        icon: Icons.phone_rounded,
                        iconColor: LogistixColors.primary,
                        title: 'Call Sender',
                        value: order.pickupPhone!,
                        onTap: () => LauncherUtils.callNumber(order.pickupPhone!),
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
                LogistixInfoTile(
                  icon: Icons.flag_rounded,
                  iconColor: Colors.orange,
                  title: 'Drop-off',
                  value: order.dropOffAddress,
                  isBold: true,
                  onTap: order.hasDropOffPosition
                      ? () => LauncherUtils.openMap(
                            order.dropOffLat!,
                            order.dropOffLng!,
                          )
                      : null,
                ),
                if (order.description != null && order.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  LogistixInfoTile(
                    icon: Icons.description_rounded,
                    iconColor: LogistixColors.textTertiary,
                    title: 'Description',
                    value: order.description!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({required this.order, required this.dateFormat});

  final Order order;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '#${order.trackingNumber}',
                maxLines: 1,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: LogistixColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: LogistixColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateFormat.format(order.createdAt.toLocal()),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: LogistixColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _StatusBadge(status: order.status),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w900,
        color: LogistixColors.textTertiary,
        letterSpacing: 1,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(LogistixRadii.md),
        border: Border.all(color: status.color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.label,
        style: context.textTheme.labelMedium?.copyWith(
          color: status.color,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}



class _BottomActionCta extends StatelessWidget {
  const _BottomActionCta({required this.order});
  final Order order;

  Widget unassignButton(BuildContext context) {
    final cubit = context.read<RiderOrderDetailsCubit>();
    return AsyncRunnerListener(
      runner: cubit.unassignRunner,
      listener: (context, state) {
        if (state.status.isSuccess) {
          context.toast.showToast(
            'Order unassigned successfully',
            type: ToastType.success,
          );
          // Stream will auto-update via Drift
        } else if (state.status.isFailure) {
          final error = state.result?.error;
          context.toast.showToast(
            error?.message ?? 'Failed to unassign order',
            type: ToastType.error,
          );
        }
      },
      child: AsyncRunnerBuilder(
        runner: cubit.unassignRunner,
        builder: (context, state, _) {
          final isLoading = state.status.isRunning;

          return OutlinedButton.icon(
            onPressed: isLoading ? null : cubit.unassignRunner.call,
            style: OutlinedButton.styleFrom(
              foregroundColor: LogistixColors.error,
              side: const BorderSide(color: LogistixColors.error),
              padding: const EdgeInsets.symmetric(
                vertical: LogistixSpacing.buttonPaddingVertical,
              ),
            ),
            icon: isLoading
                ? const SizedBox.square(
                    dimension: 16,
                    child: LogistixInlineLoader(color: LogistixColors.error),
                  )
                : const Icon(Icons.cancel_rounded),
            label: Text(
              isLoading ? 'Loading...' : 'Unassign',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  Widget startDeliveryButton(BuildContext context) {
    final cubit = context.read<RiderOrderDetailsCubit>();
    return AsyncRunnerListener(
      runner: cubit.startDeliveryRunner,
      listener: (context, state) {
        if (state.status.isSuccess) {
          context.toast.showToast('Delivery started', type: ToastType.success);
        } else if (state.status.isFailure) {
          final error = state.result?.error;
          context.toast.showToast(
            error?.message ?? 'Failed to start delivery',
            type: ToastType.error,
          );
        }
      },
      child: AsyncRunnerBuilder(
        runner: cubit.startDeliveryRunner,
        builder: (context, state, _) {
          final isLoading = state.status.isRunning;

          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : () => cubit.startDeliveryRunner(),
              style: ElevatedButton.styleFrom(
                backgroundColor: LogistixColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  vertical: LogistixSpacing.buttonPaddingVertical,
                ),
              ),
              label: Text(
                isLoading ? 'Starting...' : 'Start Delivery',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: LogistixInlineLoader(color: Colors.white),
                    )
                  : const Icon(Icons.play_arrow_rounded),
            ),
          );
        },
      ),
    );
  }

  Widget markDeliveredButton(BuildContext context) {
    final cubit = context.read<RiderOrderDetailsCubit>();
    return AsyncRunnerListener(
      runner: cubit.markDeliveredRunner,
      listener: (context, state) {
        if (state.status.isSuccess) {
          context.toast.showToast(
            'Order marked as delivered',
            type: ToastType.success,
          );
          // Stream will auto-update via Drift
        } else if (state.status.isFailure) {
          final error = state.result?.error;
          context.toast.showToast(
            error?.message ?? 'Failed to mark order as delivered',
            type: ToastType.error,
          );
        }
      },
      child: AsyncRunnerBuilder(
        runner: cubit.markDeliveredRunner,
        builder: (context, state, _) {
          final isLoading = state.status.isRunning;

          return ElevatedButton.icon(
            onPressed: isLoading ? null : cubit.markDeliveredRunner.call,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: LogistixColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: LogistixSpacing.buttonPaddingVertical,
              ),
            ),
            icon: isLoading
                ? const SizedBox.square(
                    dimension: 16,
                    child: LogistixInlineLoader(color: Colors.white),
                  )
                : const Icon(Icons.check_circle_rounded),
            label: Text(
              isLoading ? 'Marking...' : 'Mark Delivered',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget? actionButton;
    switch (order.status) {
      case OrderStatus.unassigned:
      case OrderStatus.assigned:
        actionButton = startDeliveryButton(context);
      case OrderStatus.enRoute:
        actionButton = Row(
          children: [
            Expanded(flex: 2, child: unassignButton(context)),
            const SizedBox(width: 12),
            Expanded(flex: 3, child: markDeliveredButton(context)),
          ],
        );
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        actionButton = null;
    }

    if (actionButton == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LogistixSpacing.lg,
        vertical: LogistixSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(LogistixRadii.xl),
          topRight: Radius.circular(LogistixRadii.xl),
        ),
      ),
      child: actionButton,
    );
  }
}

class _OrderDetailsShimmer extends StatelessWidget {
  const _OrderDetailsShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              const LogistixShimmer(
                height: 300,
                width: double.infinity,
                borderRadius: BorderRadius.zero,
              ),
              AppBar(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LogistixShimmer(width: 120, height: 16),
                        SizedBox(height: 8),
                        LogistixShimmer(width: 200, height: 32),
                        SizedBox(height: 12),
                        LogistixShimmer(width: 150, height: 14),
                      ],
                    ),
                    LogistixShimmer(
                      width: 100,
                      height: 36,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                const LogistixShimmer(width: 150, height: 20),
                const SizedBox(height: 20),
                LogistixShimmer(
                  width: double.infinity,
                  height: 100,
                  borderRadius: BorderRadius.circular(24),
                ),
                const SizedBox(height: 16),
                LogistixShimmer(
                  width: double.infinity,
                  height: 100,
                  borderRadius: BorderRadius.circular(24),
                ),
                const SizedBox(height: 16),
                LogistixShimmer(
                  width: double.infinity,
                  height: 100,
                  borderRadius: BorderRadius.circular(24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
