import 'package:customer/src/domain/repositories/customer_order_repository.dart';
import 'package:customer/src/features/ordering/presentation/cubit/order_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderDetailsCubit(
        context.read<CustomerOrderRepository>(),
        orderId,
      ),
      child: const _OrderDetailsView(),
    );
  }
}

class _OrderDetailsView extends StatelessWidget {
  const _OrderDetailsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LogistixColors.background,
      body: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
        builder: (context, state) {
          if (state.isLoading && state.order == null) {
            return const Center(child: BootstrapLoadingIndicator());
          }

          if (state.error != null && state.order == null) {
            return Center(
              child: BootstrapEmptyView(
                title: 'Order not found',
                description: state.error,
                icon: Icons.error_outline_rounded,
              ),
            );
          }

          final order = state.order;
          if (order == null) return const SizedBox.shrink();

          return CustomScrollView(
            slivers: [
              _OrderSliverAppBar(order: order),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(BootstrapSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _OrderHeader(order: order),
                      const SizedBox(height: BootstrapSpacing.xl),
                      _StatusBanner(order: order),
                      const SizedBox(height: BootstrapSpacing.xl),
                      const _SectionTitle(title: 'Delivery Details'),
                      const SizedBox(height: BootstrapSpacing.sm),
                      _OrderLocationInfo(order: order),
                      const SizedBox(height: BootstrapSpacing.xl),
                      const _SectionTitle(title: 'Description'),
                      const SizedBox(height: BootstrapSpacing.xs),
                      Text(
                        order.description ?? 'No extra details provided',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: LogistixColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: BootstrapSpacing.xl),
                      if (order.rider != null) ...[
                        const _SectionTitle(title: 'Assigned Rider'),
                        const SizedBox(height: BootstrapSpacing.sm),
                        _RiderCard(rider: order.rider!),
                      ],
                      const SizedBox(height: BootstrapSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OrderSliverAppBar extends StatelessWidget {
  const _OrderSliverAppBar({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [LogistixColors.primary, LogistixColors.secondaryDark],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Overview',
          style: context.textTheme.labelSmall?.copyWith(
            color: LogistixColors.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: BootstrapSpacing.xxs),
        Text(
          '#${order.trackingNumber}',
          style: context.textTheme.headlineSmall?.bold.copyWith(
            color: LogistixColors.text,
          ),
        ),
        const SizedBox(height: BootstrapSpacing.xs),
        Row(
          children: [
            const Icon(Icons.access_time_rounded, size: 14, color: LogistixColors.textTertiary),
            const SizedBox(width: BootstrapSpacing.xs),
            Text(
              dateFormat.format(order.createdAt.toLocal()),
              style: context.textTheme.bodySmall?.copyWith(color: LogistixColors.textTertiary),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final color = order.status.color;
    return Container(
      padding: const EdgeInsets.all(BootstrapSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(BootstrapSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(order.status.icon, color: color, size: 28),
          ),
          const SizedBox(width: BootstrapSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.status.label,
                  style: context.textTheme.titleSmall?.bold.copyWith(color: color),
                ),
                const SizedBox(height: BootstrapSpacing.xxs),
                Text(
                  order.status.description,
                  style: context.textTheme.bodySmall?.copyWith(color: color.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
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
      style: context.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w900,
        color: LogistixColors.textTertiary,
        letterSpacing: 1,
      ),
    );
  }
}

class _OrderLocationInfo extends StatelessWidget {
  const _OrderLocationInfo({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (order.pickupAddress.isNotEmpty ?? false) ...[
          BootstrapInfoTile(
            icon: Icons.trip_origin_rounded,
            iconColor: LogistixColors.primary,
            title: 'Pickup',
            value: order.pickupAddress,
            onTap: order.hasPickupPosition
                ? () => LogistixLauncher.openMap(order.pickupLat!, order.pickupLng!)
                : null,
          ),
          const SizedBox(height: BootstrapSpacing.sm),
        ],
        BootstrapInfoTile(
          icon: Icons.flag_rounded,
          iconColor: Colors.orange,
          title: 'Drop-off',
          value: order.dropOffAddress,
          isBold: true,
          onTap: order.hasDropOffPosition
              ? () => LogistixLauncher.openMap(order.dropOffLat!, order.dropOffLng!)
              : null,
        ),
      ],
    );
  }
}

class _RiderCard extends StatelessWidget {
  const _RiderCard({required this.rider});
  final Rider rider;

  @override
  Widget build(BuildContext context) {
    return BootstrapCard(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: LogistixColors.primary.withValues(alpha: 0.1),
          child: const Icon(Icons.person_outline_rounded, color: LogistixColors.primary),
        ),
        title: Text(rider.fullName, style: context.textTheme.titleSmall?.bold),
        subtitle: Text(rider.phoneNumber ?? 'No phone'),
        trailing: rider.phoneNumber != null
            ? IconButton(
                icon: const Icon(Icons.call_rounded, color: LogistixColors.success),
                onPressed: () => LogistixLauncher.callNumber(rider.phoneNumber!),
              )
            : null,
      ),
    );
  }
}
