import 'package:dispatcher/src/features/deliveries/presentation/cubit/deliveries_cubit.dart';
import 'package:dispatcher/src/features/deliveries/presentation/widgets/delivery_summary_card.dart';
import 'package:dispatcher/src/presentation/router/dispatcher_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class DeliveriesTab extends StatelessWidget {
  const DeliveriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final deliveriesCubit = context.read<DeliveriesCubit>();

    return BlocBuilder<DeliveriesCubit, DeliveriesState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: LogistixColors.background,
          body: CustomScrollView(
            controller: deliveriesCubit.scrollController,
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
                            colors: [LogistixColors.primary, LogistixColors.secondaryDark],
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
                          padding: EdgeInsets.only(bottom: BootstrapSpacing.lg),
                          child: DeliverySummaryCard(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              PinnedHeaderSliver(
                child: Container(
                  color: LogistixColors.background,
                  padding: const EdgeInsets.symmetric(vertical: BootstrapSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: BootstrapSpacing.lg,
                        ),
                        child: BootstrapSearchField(
                          onChanged: deliveriesCubit.searchDeliveries,
                          hintText: 'Search deliveries or trackings...',
                        ),
                      ),
                      const SizedBox(height: BootstrapSpacing.md),
                      const _StatusFilterList(),
                    ],
                  ),
                ),
              ),
              if (state.deliveries.isEmpty && !state.isLoading)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: (state.searchQuery?.isEmpty ?? true)
                      ? const BootstrapEmptyView(
                          icon: Icons.list_alt_rounded,
                          title: 'No Deliveries Found',
                          description:
                              'Create your first delivery to get started!',
                        )
                      : const BootstrapEmptyView(
                          icon: Icons.search_off_rounded,
                          title: 'No results matching your query',
                          description: 'Try adjusting your search or filters.',
                        ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: BootstrapSpacing.lg,
                    right: BootstrapSpacing.lg,
                    bottom: 100, // Fab clearance
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == state.deliveries.length) {
                          if (state.isLoadingMore) {
                            return Padding(
                              padding: const EdgeInsets.all(
                                BootstrapSpacing.md,
                              ),
                              child: BootstrapShimmer(
                                width: double.infinity,
                                height: 120,
                                borderRadius: BorderRadius.circular(BootstrapRadii.card),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }
                        final delivery = state.deliveries[index];
                        return BootstrapEntrance(
                          delay: Duration(milliseconds: index * 50),
                          children: [
                            DeliveryPreviewCard(
                              delivery: delivery,
                              onTap: () => context.push(
                                DispatcherRoutes.deliveryDetails(delivery.id),
                              ),
                            ),
                          ],
                        );
                      },
                      childCount:
                          state.deliveries.length +
                          (state.isLoadingMore && state.hasMore ? 1 : 0),
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push(DispatcherRoutes.createDelivery),
            backgroundColor: LogistixColors.primary,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(BootstrapRadii.xl),
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
    final deliveriesCubit = context.read<DeliveriesCubit>();
    return BlocBuilder<DeliveriesCubit, DeliveriesState>(
      builder: (context, state) {
        const allStatuses = DeliveryStatus.values;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: BootstrapSpacing.lg),
          clipBehavior: Clip.none, // Prevent shadow clipping
          child: Row(
            children: [
              BootstrapChoiceChip(
                label: 'All',
                isSelected: state.selectedStatus == null,
                onTap: () => deliveriesCubit.filterByStatus(null),
              ),
              ...allStatuses.map((status) {
                final isSelected = state.selectedStatus == status;
                return BootstrapChoiceChip(
                  label: status.label,
                  isSelected: isSelected,
                  onTap: () => deliveriesCubit.filterByStatus(status),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
