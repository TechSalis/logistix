import 'package:dispatcher/src/features/orders/presentation/cubit/metrics_cubit.dart';
import 'package:dispatcher/src/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:dispatcher/src/features/orders/presentation/widgets/order_summary_card.dart';
import 'package:dispatcher/src/presentation/router/dispatcher_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersCubit = context.read<OrdersCubit>();
    if (ordersCubit.state.orders.isEmpty && !ordersCubit.state.isLoading) {
      ordersCubit.loadInitial();
      context.read<MetricsCubit>().loadMetrics();
    }

    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        return Scaffold(
          body: CustomScrollView(
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
                            colors: [LogistixColors.primary, Color(0xFF6366F1)],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 16,
                        top: MediaQuery.viewPaddingOf(context).top + 8,
                        child: OrderSummaryCard(
                          onRetry: context.read<MetricsCubit>().loadMetrics,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              PinnedHeaderSliver(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _SearchField(
                          onChanged: ordersCubit.searchOrders,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _StatusFilterList(),
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
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: (state.searchQuery?.isEmpty ?? true)
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.list_alt_rounded,
                                size: 64,
                                color: LogistixColors.textTertiary,
                              ),
                              SizedBox(height: 16),
                              Text('You have no orders yet'),
                            ],
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 64,
                                color: LogistixColors.textTertiary,
                              ),
                              SizedBox(height: 16),
                              Text('No orders matching your criteria'),
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
                              DispatcherRoutes.orderDetails(order.id),
                            ),
                          ),
                        );
                      },
                      childCount: state.orders.length + (state.hasMore ? 1 : 0),
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push(DispatcherRoutes.createOrder),
            backgroundColor: LogistixColors.primary,
            child: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search tracking number, address...',
          hintStyle: context.textTheme.bodyMedium?.copyWith(
            color: LogistixColors.textTertiary,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: LogistixColors.primary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

class _StatusFilterList extends StatelessWidget {
  const _StatusFilterList();

  @override
  Widget build(BuildContext context) {
    final ordersCubit = context.read<OrdersCubit>();
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        const allStatuses = OrderStatus.values;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _StatusChip(
                label: 'All',
                isSelected: state.selectedStatuses.isEmpty,
                onTap: () => ordersCubit.filterByStatus([]),
              ),
              ...allStatuses.map((s) {
                final status = s.value;
                final isSelected = state.selectedStatuses.contains(status);
                return _StatusChip(
                  label: s.name.capitalize,
                  isSelected: isSelected,
                  onTap: () {
                    final newList = List<String>.from(state.selectedStatuses);
                    if (isSelected) {
                      newList.remove(status);
                    } else {
                      newList.add(status);
                    }
                    ordersCubit.filterByStatus(newList);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedScaleTap(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? LogistixColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? LogistixColors.primary : LogistixColors.border,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: LogistixColors.primary.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            color: isSelected ? Colors.white : LogistixColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
