import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:rider/src/features/deliveries/presentation/cubit/rider_deliveries_cubit.dart';
import 'package:rider/src/features/deliveries/presentation/widgets/rider_metrics_card.dart';
import 'package:rider/src/presentation/router/rider_routes.dart';
import 'package:shared/shared.dart';

class RiderDeliveriesTab extends StatefulWidget {
  const RiderDeliveriesTab({super.key});

  @override
  State<RiderDeliveriesTab> createState() => _RiderDeliveriesTabState();
}

class _RiderDeliveriesTabState extends State<RiderDeliveriesTab> {
  late RiderDeliveriesCubit deliveriesCubit;

  @override
  void initState() {
    super.initState();
    deliveriesCubit = context.read<RiderDeliveriesCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<RiderDeliveriesCubit, RiderDeliveriesState>(
        builder: (context, state) {
          return CustomScrollView(
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
                          padding: EdgeInsets.only(bottom: 24),
                          child: RiderMetricsCard(),
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
                        child: _SearchField(
                          onChanged: deliveriesCubit.searchDeliveries,
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
                          title: 'No Active Deliveries',
                          description:
                              'You have no assigned deliveries at the moment.',
                        )
                      : const BootstrapEmptyView(
                          icon: Icons.search_off_rounded,
                          title: 'No deliveries found',
                          description: 'Try adjusting your search filters.',
                        ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    BootstrapSpacing.lg,
                    0,
                    BootstrapSpacing.lg,
                    100,
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
                                borderRadius: BorderRadius.circular(24),
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
                                RiderRoutes.deliveryDetails(delivery.id),
                                extra: delivery,
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
          );
        },
      ),
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
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        style: context.textTheme.bodyMedium?.bold,
        decoration: InputDecoration(
          hintText: 'Search or track deliveries...',
          hintStyle: context.textTheme.bodyMedium?.copyWith(
            color: LogistixColors.textTertiary,
            fontWeight: FontWeight.normal,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: LogistixColors.primary,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _StatusFilterList extends StatelessWidget {
  const _StatusFilterList();

  @override
  Widget build(BuildContext context) {
    final deliveriesCubit = context.read<RiderDeliveriesCubit>();
    return BlocBuilder<RiderDeliveriesCubit, RiderDeliveriesState>(
      builder: (context, state) {
        final riderStatuses = [
          DeliveryStatus.PENDING,
          DeliveryStatus.ASSIGNED,
          DeliveryStatus.EN_ROUTE,
          DeliveryStatus.DELIVERED,
        ];

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: BootstrapSpacing.lg),
          child: Row(
            children: [
              _StatusChip(
                label: 'All',
                isSelected: state.selectedStatus == null,
                onTap: () => deliveriesCubit.filterByStatus(null),
              ),
              ...riderStatuses.map((status) {
                final isSelected = state.selectedStatus == status;
                return _StatusChip(
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
        margin: const EdgeInsets.only(right: BootstrapSpacing.xs),
        padding: const EdgeInsets.symmetric(
            horizontal: BootstrapSpacing.md, vertical: BootstrapSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? LogistixColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? LogistixColors.primary
                : LogistixColors.border.withValues(alpha: 0.5),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: LogistixColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          label,
          style: context.textTheme.labelSmall?.bold.copyWith(
            color: isSelected ? Colors.white : LogistixColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
