import 'package:dispatcher/src/domain/usecases/search_riders_usecase.dart';
import 'package:dispatcher/src/features/orders/domain/repositories/order_repository.dart';
import 'package:dispatcher/src/features/orders/presentation/cubit/order_details_cubit.dart';
import 'package:dispatcher/src/features/orders/presentation/widgets/order_action_bar.dart';
import 'package:dispatcher/src/features/orders/presentation/widgets/order_address_section.dart';
import 'package:dispatcher/src/features/orders/presentation/widgets/order_map_header.dart';
import 'package:dispatcher/src/features/riders/presentation/widgets/rider_dropdown_search.dart';
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
      create: (context) => OrderDetailsCubit(context.read<OrderRepository>())..loadOrder(orderId),
      child: _OrderDetailsView(orderId),
    );
  }
}

class _OrderDetailsView extends StatelessWidget {
  const _OrderDetailsView(this.orderId);
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
        builder: (context, state) {
          if (state is OrderDetailsInitial) return const SizedBox.shrink();
          if (state is OrderDetailsLoading) return const _OrderDetailsShimmer();
          if (state is OrderDetailsError) return BootstrapErrorView(message: state.message);
          if (state is OrderDetailsLoaded) return _OrderLoadedContent(order: state.order);
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
        builder: (context, state) {
          if (state is OrderDetailsLoaded) return OrderActionBar(order: state.order);
          return const SizedBox.shrink();
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
      slivers: [
        OrderMapHeader(order: order),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: BootstrapSpacing.lg,
              vertical: BootstrapSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OrderHeader(order: order, dateFormat: dateFormat),
                const SizedBox(height: BootstrapSpacing.xl),

                // Premium details card
                Container(
                  decoration: BoxDecoration(
                    color: LogistixColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: LogistixColors.black.withValues(alpha: 0.03)),
                    boxShadow: [
                      BoxShadow(
                        color: LogistixColors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(BootstrapSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OrderAddressSection(order: order),
                      
                      if (order.description?.isNotEmpty ?? false) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: BootstrapSpacing.sm),
                          child: Divider(height: 1, color: LogistixColors.background),
                        ),
                        BootstrapInfoTile(
                          icon: Icons.description_rounded,
                          iconColor: LogistixColors.textTertiary,
                          title: 'Description',
                          value: order.description!,
                          isDimmed: true,
                        ),
                      ],
                    ],
                  ),
                ),
                
                if (order.scheduledAt != null) ...[
                  const SizedBox(height: BootstrapSpacing.md),
                  Container(
                    decoration: BoxDecoration(
                      color: LogistixColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: LogistixColors.primary.withValues(alpha: 0.1)),
                    ),
                    padding: const EdgeInsets.all(BootstrapSpacing.md),
                    child: BootstrapInfoTile(
                      icon: Icons.calendar_today_rounded,
                      iconColor: LogistixColors.primary,
                      title: 'Scheduled Delivery',
                      value: order.scheduledAt!.toScheduleString(),
                      isBold: true,
                    ),
                  ),
                ],
                
                const SizedBox(height: BootstrapSpacing.xl),
                _RiderSection(order: order),
                const SizedBox(height: BootstrapSpacing.xl),
                
                Builder(
                  builder: (context) {
                    final user = context.read<UserStore>().user;
                    final tier = user?.companyProfile?.config?.tier ?? BillingTier.free;
                    final isFreeTier = tier == BillingTier.free;

                    return Center(
                      child: BootstrapButton(
                        onPressed: isFreeTier 
                            ? null 
                            : () => context.read<OrderDetailsCubit>().shareOrder(order),
                        label: isFreeTier ? 'Upgrade to Share Link' : 'Share Tracking Link',
                        icon: isFreeTier ? Icons.lock_rounded : Icons.share_rounded,
                        type: BootstrapButtonType.outline,
                        width: 280,
                      ),
                    );
                  }
                ),
                const SizedBox(height: BootstrapSpacing.xl),
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
                'Order Overview',
                style: context.textTheme.labelSmall?.copyWith(
                  color: LogistixColors.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '#${order.trackingNumber}',
                    style: context.textTheme.headlineMedium?.bold,
                  ),
                  if (order.companyId == null) ...[
                    const SizedBox(width: 8),
                    const _ExternalAppBadge(),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              _CreatedAtRow(date: order.createdAt),
            ],
          ),
        ),
        _StatusBadge(status: order.status),
      ],
    );
  }
}

class _CreatedAtRow extends StatelessWidget {
  const _CreatedAtRow({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.access_time_rounded, size: 14, color: LogistixColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          DateFormat('MMM dd, yyyy • hh:mm a').format(date.toLocal()),
          style: context.textTheme.bodySmall?.copyWith(color: LogistixColors.textSecondary),
        ),
      ],
    );
  }
}

class _ExternalAppBadge extends StatelessWidget {
  const _ExternalAppBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: LogistixColors.secondary, borderRadius: BorderRadius.circular(BootstrapRadii.xs)),
      child: Text('APP', style: context.textTheme.labelSmall?.bold.copyWith(color: LogistixColors.white)),
    );
  }
}

class _RiderSection extends StatelessWidget {
  const _RiderSection({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    if (order.rider == null && order.status.isCompleted) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rider Assignment',
          style: context.textTheme.labelMedium?.bold.copyWith(color: LogistixColors.textTertiary, letterSpacing: 1),
        ),
        const SizedBox(height: BootstrapSpacing.md),
        AssignRiderDropdownSearch(
          selectedRider: order.rider,
          searchRiders: (filter) => context.read<SearchRidersUseCase>().call(
            filter,
            lat: order.dropOffLat ?? order.pickupLat,
            lng: order.dropOffLng ?? order.pickupLng,
          ),
          onChanged: (rider) {
            if (rider != null) context.read<OrderDetailsCubit>().assignRunner(rider);
          },
          onUnassign: () => context.read<OrderDetailsCubit>().unassignRunner(),
          isCompleted: order.status.isCompleted,
        ),
      ],
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
        borderRadius: BorderRadius.circular(BootstrapRadii.md),
        border: Border.all(color: status.color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.label,
        style: context.textTheme.labelMedium?.bold.copyWith(color: status.color, letterSpacing: 0.5),
      ),
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
          const BootstrapShimmer(height: 300, width: double.infinity, borderRadius: BorderRadius.zero),
          Padding(
            padding: const EdgeInsets.all(BootstrapSpacing.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BootstrapShimmer(width: double.infinity, height: 80),
                const SizedBox(height: 40),
                const BootstrapShimmer(width: 150, height: 20),
                const SizedBox(height: 20),
                for (var i = 0; i < 3; i++) ...[
                  BootstrapShimmer(width: double.infinity, height: 100, borderRadius: BorderRadius.circular(BootstrapRadii.xxl)),
                  const SizedBox(height: BootstrapSpacing.md),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
