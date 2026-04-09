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

    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: LogistixColors.background,
          body: CustomScrollView(
            controller: ordersCubit.scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverAppBar(
                pinned: true,
                stretch: true,
                toolbarHeight: 0,
                collapsedHeight: 0,
                expandedHeight: 160,
                backgroundColor: LogistixColors.primary,
                systemOverlayStyle: SystemUiOverlayStyle.light,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.fadeTitle,
                  ],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [LogistixColors.primary, Color(0xFF4F46E5)],
                          ),
                        ),
                      ),
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: OrderSummaryCard(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              PinnedHeaderSliver(
                child: Container(
                  color: LogistixColors.background,
                  padding: const EdgeInsets.symmetric(vertical: LogistixSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: LogistixSpacing.lg,
                        ),
                        child: LogistixSearchField(
                          onChanged: ordersCubit.searchOrders,
                          hintText: 'Search orders or trackings...',
                        ),
                      ),
                      const SizedBox(height: LogistixSpacing.md),
                      const _StatusFilterList(),
                    ],
                  ),
                ),
              ),
              if (state.orders.isEmpty && !state.isLoading)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: (state.searchQuery?.isEmpty ?? true)
                      ? const LogistixEmptyView(
                          icon: Icons.list_alt_rounded,
                          title: 'No Orders Found',
                          description:
                              'Create your first order to get started!',
                        )
                      : const LogistixEmptyView(
                          icon: Icons.search_off_rounded,
                          title: 'No results matching your query',
                          description: 'Try adjusting your search or filters.',
                        ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    LogistixSpacing.lg,
                    0,
                    LogistixSpacing.lg,
                    100,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == state.orders.length) {
                          if (state.isLoadingMore) {
                            return Padding(
                              padding: const EdgeInsets.all(
                                LogistixSpacing.md,
                              ),
                              child: LogistixShimmer(
                                width: double.infinity,
                                height: 120,
                                borderRadius: BorderRadius.circular(24),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }
                        final order = state.orders[index];
                        return LogistixEntrance(
                          delay: Duration(milliseconds: index * 50),
                          children: [
                            OrderPreviewCard(
                              order: order,
                              onTap: () => context.push(
                                DispatcherRoutes.orderDetails(order.id),
                              ),
                            ),
                          ],
                        );
                      },
                      childCount:
                          state.orders.length +
                          (state.isLoadingMore && state.hasMore ? 1 : 0),
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push(DispatcherRoutes.createOrder),
            backgroundColor: LogistixColors.primary,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
        );
      },
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
          padding: const EdgeInsets.symmetric(horizontal: LogistixSpacing.lg),
          child: Row(
            children: [
              LogistixChoiceChip(
                label: 'All',
                isSelected: state.selectedStatus == null,
                onTap: () => ordersCubit.filterByStatus(null),
              ),
              ...allStatuses.map((status) {
                final isSelected = state.selectedStatus == status;
                return LogistixChoiceChip(
                  label: status.label,
                  isSelected: isSelected,
                  onTap: () => ordersCubit.filterByStatus(status),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}


