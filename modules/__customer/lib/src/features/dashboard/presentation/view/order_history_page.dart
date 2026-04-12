import 'package:customer/src/features/dashboard/presentation/cubit/order_history_cubit.dart';
import 'package:customer/src/presentation/router/customer_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    const threshold = 200.0;
    final position = _scrollController.position;
    if (position.maxScrollExtent - position.pixels <= threshold) {
      context.read<OrderHistoryCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderHistoryCubit, OrderHistoryState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: LogistixColors.background,
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 120,
                backgroundColor: LogistixColors.primary,
                systemOverlayStyle: SystemUiOverlayStyle.light,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Order History',
                    style: context.textTheme.titleLarge?.bold.copyWith(color: Colors.white),
                  ),
                  background: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [LogistixColors.primary, LogistixColors.secondaryDark],
                      ),
                    ),
                  ),
                ),
              ),
              if (state.isLoading && state.orders.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: BootstrapLoadingIndicator()),
                )
              else if (state.error != null && state.orders.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: BootstrapEmptyView(
                      title: 'Error loading history',
                      description: state.error,
                      icon: Icons.error_outline_rounded,
                      action: BootstrapButton(
                        onPressed: () => context.read<OrderHistoryCubit>().refresh(),
                        label: 'Retry',
                      ),
                    ),
                  ),
                )
              else if (state.orders.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: BootstrapEmptyView(
                      title: 'No orders yet',
                      description: 'Your order history will appear here once you place an order.',
                      icon: Icons.history_rounded,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    BootstrapSpacing.lg,
                    BootstrapSpacing.md,
                    BootstrapSpacing.lg,
                    100,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == state.orders.length) {
                          return state.isLoadingMore
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(child: BootstrapLoadingIndicator()),
                                )
                              : const SizedBox.shrink();
                        }
                        
                        final order = state.orders[index];
                        return BootstrapEntrance(
                          delay: Duration(milliseconds: index * 40),
                          children: [
                            OrderPreviewCard(
                              order: order,
                              onTap: () => context.push(
                                CustomerRoutes.orderDetails(order.id),
                              ),
                            ),
                          ],
                        );
                      },
                      childCount: state.orders.length + (state.hasMore ? 1 : 0),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
