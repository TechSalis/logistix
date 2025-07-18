import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:implicitly_animated_list/implicitly_animated_list.dart';
import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/features/home/domain/entities/rider_data.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/app/router/app_router.dart';
import 'package:logistix/features/orders/application/logic/orders_rp.dart';
import 'package:logistix/features/orders/presentation/widgets/order_cards.dart';
import 'package:logistix/features/rider/application/find_rider_rp.dart';
import 'package:logistix/features/rider/presentation/widgets/rider_profile_group.dart';
import 'package:logistix/features/rider/presentation/widgets/rider_tracker_widget.dart';

class OrdersTab extends ConsumerStatefulWidget {
  const OrdersTab({super.key});

  @override
  ConsumerState<OrdersTab> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersTab>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;

  @override
  initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);

    if (ref.read(ordersProvider).value?.data.isEmpty ?? false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.watch(ordersProvider.notifier).getOngoing();
      });
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          Consumer(
            builder: (context, ref, child) {
              final rider =
                  ref.watch(findRiderProvider) is RiderContactedState
                      ? (ref.watch(findRiderProvider) as RiderContactedState)
                          .rider
                      : null;
              return SliverAppBar(
                pinned: true,
                stretch: rider != null,
                toolbarHeight: 0,
                expandedHeight: rider != null ? .33.sh : null,
                stretchTriggerOffset: 80,
                onStretchTrigger: () async {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Tap on the map to open")),
                    );
                  });
                },
                flexibleSpace:
                    rider != null
                        ? FlexibleSpaceBar(
                          collapseMode: CollapseMode.parallax,
                          background: Transform.translate(
                            offset: const Offset(0, -kToolbarHeight * .5),
                            child: _RiderTrackerCard(
                              rider: rider,
                              eta: '20 mins',
                            ),
                          ),
                        )
                        : null,
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(rider != null ? 108 : 52),
                  child: ColoredBox(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Column(
                      children: [
                        if (rider != null) _TrackingRiderTitleBar(rider: rider),
                        TabBar(
                          controller: tabController,
                          indicatorColor: Theme.of(context).colorScheme.primary,
                          tabs: const [Tab(text: 'Ongoing'), Tab(text: 'All')],
                          onTap: (value) {
                            if (value == 0) {
                              ref.read(ordersProvider.notifier).getOngoing();
                            } else if (value == 1) {
                              ref.read(ordersProvider.notifier).getAll();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Consumer(
            builder: (context, ref, child) {
              return ref
                  .watch(ordersProvider)
                  .when(
                    skipError: true,
                    skipLoadingOnReload: true,
                    skipLoadingOnRefresh: true,
                    loading: () {
                      return const SliverFillRemaining(
                        fillOverscroll: false,
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    error: (error, stackTrace) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        fillOverscroll: false,
                        child: Center(
                          child: Text(
                            (error as AppError).message,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      );
                    },
                    data: (state) {
                      final data = switch (tabController.index) {
                        0 => state.data[OrdersState.onGoing],
                        1 => state.data[OrdersState.history],
                        _ => throw FlutterError('More tabs than Tabviews'),
                      };
                      if (data == null || data.orders.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          fillOverscroll: false,
                          child: Center(
                            child: Text(
                              'No orders yet!',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        );
                      }
                      return _OrdersSliverList(data: data);
                    },
                  );
            },
          ),
        ],
      ),
    );
  }
}

class _OrdersSliverList extends StatelessWidget {
  const _OrdersSliverList({required this.data});

  final OrderTabData data;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      sliver: SliverImplicitlyAnimatedList(
        itemData: data.orders.toList(growable: false),
        itemBuilder: (context, item) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: OrderCard(
                  order: item,
                  onTap: () => OrderDetailsPageRoute(item).push(context),
                ),
              ),
              if (item == data.orders.last && !data.page.isLast)
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 32, top: 12),
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(
                      height: 40,
                      child: Consumer(
                        builder: (context, ref, child) {
                          if (ref.watch(ordersProvider).isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return TextButton(
                            onPressed: () {},
                            child: const Text('Show more'),
                          );
                        },
                      ),
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

class _TrackingRiderTitleBar extends StatelessWidget {
  const _TrackingRiderTitleBar({required this.rider});
  final RiderData rider;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: const Border(),
      child: Padding(
        padding: padding_H16_V12,
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => ChatPageRoute(rider).push(context),
                child: RiderProfileGroup(user: rider),
              ),
            ),
            const Chip(
              visualDensity: VisualDensity(vertical: -4),
              label: Row(
                children: [
                  Icon(Icons.my_location, size: 14),
                  SizedBox(width: 4),
                  Text('Tracking'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiderTrackerCard extends StatelessWidget {
  const _RiderTrackerCard({required this.rider, required this.eta});
  final RiderData rider;
  final String eta;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => RiderTrackerPageRoute(rider).push(context),
      child: AbsorbPointer(child: RiderTrackerMapWidget(rider: rider)),
    );
  }
}
