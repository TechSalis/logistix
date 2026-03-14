import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:rider/src/features/orders/presentation/cubit/rider_orders_cubit.dart';
import 'package:rider/src/features/orders/presentation/widgets/rider_metrics_card.dart';
import 'package:rider/src/presentation/bloc/rider_bloc.dart';
import 'package:rider/src/presentation/bloc/rider_state.dart';
import 'package:rider/src/presentation/router/rider_routes.dart';
import 'package:shared/shared.dart';

class RiderOrdersTab extends StatefulWidget {
  const RiderOrdersTab({super.key});

  @override
  State<RiderOrdersTab> createState() => _RiderOrdersTabState();
}

class _RiderOrdersTabState extends State<RiderOrdersTab> {
  @override
  void initState() {
    super.initState();
    // Load initial orders and metrics when tab is first opened
    final ordersCubit = context.read<RiderOrdersCubit>();
    final riderBloc = context.read<RiderBloc>();

    // Set up metrics callback
    riderBloc.onMetricsUpdated = ordersCubit.handleMetricsUpdate;

    if (ordersCubit.state.orders.isEmpty && !ordersCubit.state.isLoading) {
      ordersCubit.loadInitial();
    } else if (ordersCubit.state.metrics == null &&
        !ordersCubit.state.isLoadingMetrics) {
      // Load metrics even if orders are already loaded
      ordersCubit.loadMetrics();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<RiderBloc, RiderState>(
        listenWhen: (previous, current) {
          // Listen to order updates from RiderBloc
          final prevOrders = previous.mapOrNull(loaded: (s) => s.orders);
          final currOrders = current.mapOrNull(loaded: (s) => s.orders);
          return prevOrders != currOrders;
        },
        listener: (context, state) {
          // Propagate order updates to RiderOrdersCubit
          state.mapOrNull(
            loaded: (s) {
              if (s.orders.isNotEmpty) {
                final lastOrder = s.orders.first;
                context.read<RiderOrdersCubit>().handleOrderUpdate(lastOrder);
              }
            },
          );
        },
        child: BlocBuilder<RiderOrdersCubit, RiderOrdersState>(
          builder: (context, state) {
            final ordersCubit = context.read<RiderOrdersCubit>();
            final isAssignedFilter = state.selectedStatuses.contains(
              OrderStatus.assigned,
            );

            return CustomScrollView(
              controller: ordersCubit.scrollController,
              slivers: [
                SliverAppBar(
                  pinned: true,
                  toolbarHeight: 0,
                  collapsedHeight: 0,
                  expandedHeight: 140,
                  backgroundColor: LogistixColors.primary,
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                LogistixColors.primary,
                                Color(0xFF6366F1),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 16,
                          top: MediaQuery.viewPaddingOf(context).top + 8,
                          child: RiderMetricsCard(
                            onRetry: ordersCubit.loadMetrics,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PinnedHeaderSliver(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _FilterTab(
                          title: 'Assigned',
                          isSelected: isAssignedFilter,
                          onTap: () => ordersCubit.filterByStatus([
                            OrderStatus.assigned,
                            OrderStatus.enRoute,
                          ]),
                        ),
                        const SizedBox(width: 12),
                        _FilterTab(
                          title: 'History',
                          isSelected: !isAssignedFilter,
                          onTap: () => ordersCubit.filterByStatus([
                            OrderStatus.delivered,
                            OrderStatus.cancelled,
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.isLoading && state.orders.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: LogistixShimmer(
                            width: double.infinity,
                            height: 120,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      }, childCount: 5),
                    ),
                  )
                else if (state.error != null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: LogistixErrorView(
                      message: state.error!,
                      onRetry: ordersCubit.loadInitial,
                    ),
                  )
                else if (state.orders.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.list_alt_rounded,
                            size: 64,
                            color: LogistixColors.textTertiary,
                          ),
                          SizedBox(height: 16),
                          Text('No orders found'),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == state.orders.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: LogistixShimmer(
                                width: double.infinity,
                                height: 120,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            );
                          }
                          final order = state.orders[index];
                          return SlideFadeTransition(
                            child: OrderPreviewCard(
                              order: order,
                              onTap: () => context.push(
                                RiderRoutes.orderDetails(order.id),
                                extra: order,
                              ),
                            ),
                          );
                        },
                        childCount:
                            state.orders.length + (state.hasMore ? 1 : 0),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedScaleTap(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? LogistixColors.primary
                : LogistixColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? LogistixColors.primary
                  : LogistixColors.border,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: LogistixColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: context.textTheme.labelLarge?.copyWith(
              color: isSelected ? Colors.white : LogistixColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
