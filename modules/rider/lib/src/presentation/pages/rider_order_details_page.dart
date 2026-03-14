import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
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
            error: (message) => LogistixErrorView(
              message: message,
              onRetry: () {
                context.read<RiderOrderDetailsCubit>().loadOrder(orderId);
              },
            ),
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
                _InfoCard(
                  title: 'Pickup Address',
                  content: order.pickupAddress,
                  icon: Icons.trip_origin_rounded,
                  iconColor: LogistixColors.primary,
                ),
                const SizedBox(height: LogistixSpacing.md),
                if (order.dropOffAddress != null) ...[
                  _InfoCard(
                    title: 'Drop-off Address',
                    content: order.dropOffAddress!,
                    icon: Icons.flag_rounded,
                    iconColor: Colors.orange,
                  ),
                  const SizedBox(height: LogistixSpacing.md),
                ],
                if (order.items != null) ...[
                  _InfoCard(
                    title: 'Package Items',
                    content: order.items!,
                    icon: Icons.inventory_2_rounded,
                  ),
                  const SizedBox(height: LogistixSpacing.md),
                ],
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _InfoCard(
                        title: 'Customer',
                        content: order.customerName ?? 'Unknown Customer',
                        icon: Icons.person_rounded,
                        onIconTap: order.customerPhone != null
                            ? () {
                                // Call customer
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(width: LogistixSpacing.md),
                    Expanded(
                      flex: 2,
                      child: _InfoCard(
                        title: 'COD',
                        content: order.codAmount != null
                            ? '₦${order.codAmount!.toStringAsFixed(0)}'
                            : 'None',
                        icon: Icons.payments_rounded,
                        iconColor: Colors.green,
                      ),
                    ),
                  ],
                ),
                if (order.description != null &&
                    order.description!.isNotEmpty) ...[
                  const SizedBox(height: LogistixSpacing.xl),
                  const _SectionTitle(title: 'NOTES'),
                  const SizedBox(height: LogistixSpacing.md),
                  _InfoCard(
                    title: 'Special Instructions',
                    content: order.description!,
                    icon: Icons.note_rounded,
                    iconColor: Colors.blueAccent,
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
        status.value,
        style: context.textTheme.labelMedium?.copyWith(
          color: status.color,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.content,
    required this.icon,
    this.iconColor,
    this.onIconTap,
  });

  final String title;
  final String content;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onIconTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LogistixSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LogistixRadii.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: LogistixColors.border.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (iconColor ?? LogistixColors.textTertiary).withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor ?? LogistixColors.textSecondary,
            ),
          ),
          const SizedBox(width: LogistixSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: LogistixColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: context.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: LogistixColors.text,
                  ),
                ),
              ],
            ),
          ),
          if (onIconTap != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onIconTap,
                borderRadius: BorderRadius.circular(LogistixRadii.sm),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.call_rounded,
                    size: 20,
                    color: LogistixColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BottomActionCta extends StatelessWidget {
  const _BottomActionCta({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RiderOrderDetailsCubit>();

    Widget? actionButton;

    switch (order.status) {
      case OrderStatus.assigned:
        actionButton = ElevatedButton.icon(
          onPressed: () => cubit.updateStatus(OrderStatus.enRoute),
          style: ElevatedButton.styleFrom(
            backgroundColor: LogistixColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          label: const Text(
            'Start Delivery',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          icon: const Icon(Icons.play_arrow_rounded),
        );
      case OrderStatus.enRoute:
        actionButton = Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => cubit.updateStatus(OrderStatus.cancelled),
                style: OutlinedButton.styleFrom(
                  foregroundColor: LogistixColors.error,
                  side: const BorderSide(color: LogistixColors.error),
                ),
                icon: const Icon(Icons.cancel_rounded),
                label: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => cubit.updateStatus(OrderStatus.delivered),
                style: ElevatedButton.styleFrom(
                  backgroundColor: LogistixColors.success,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text(
                  'Mark Delivered',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
      case OrderStatus.unassigned:
        actionButton = null;
    }

    if (actionButton == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(
        LogistixSpacing.lg,
        LogistixSpacing.md,
        LogistixSpacing.lg,
        LogistixSpacing.md,
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
