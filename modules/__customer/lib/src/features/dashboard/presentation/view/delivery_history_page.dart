import 'package:customer/src/features/dashboard/presentation/cubit/delivery_history_cubit.dart';
import 'package:customer/src/presentation/router/customer_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class DeliveryHistoryPage extends StatefulWidget {
  const DeliveryHistoryPage({super.key});

  @override
  State<DeliveryHistoryPage> createState() => _DeliveryHistoryPageState();
}

class _DeliveryHistoryPageState extends State<DeliveryHistoryPage> {
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
      context.read<DeliveryHistoryCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeliveryHistoryCubit, DeliveryHistoryState>(
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
                    'Delivery History',
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
              if (state.isLoading && state.deliveries.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: BootstrapLoadingIndicator()),
                )
              else if (state.error != null && state.deliveries.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: BootstrapEmptyView(
                      title: 'Error loading history',
                      description: state.error,
                      icon: Icons.error_outline_rounded,
                      action: BootstrapButton(
                        onPressed: () => context.read<DeliveryHistoryCubit>().refresh(),
                        label: 'Retry',
                      ),
                    ),
                  ),
                )
              else if (state.deliveries.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: BootstrapEmptyView(
                      title: 'No deliveries yet',
                      description: 'Your delivery history will appear here once you place an delivery.',
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
                        if (index == state.deliveries.length) {
                          return state.isLoadingMore
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(child: BootstrapLoadingIndicator()),
                                )
                              : const SizedBox.shrink();
                        }
                        
                        final delivery = state.deliveries[index];
                        return BootstrapEntrance(
                          delay: Duration(milliseconds: index * 40),
                          children: [
                            DeliveryPreviewCard(
                              delivery: delivery,
                              onTap: () => context.push(
                                CustomerRoutes.deliveryDetails(delivery.id),
                              ),
                            ),
                          ],
                        );
                      },
                      childCount: state.deliveries.length + (state.hasMore ? 1 : 0),
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
