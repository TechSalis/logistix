import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/entities/rider_data.dart';
import 'package:logistix/core/utils/router.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';
import 'package:logistix/features/orders/presentation/widgets/order_card.dart';
import 'package:logistix/features/rider/presentation/widgets/rider_tracker_widget.dart';

const orders = [
  Order(
    id: '1',
    type: OrderType.food,
    pickUp: Address(
      'Burger Place. Hilltop',
      coordinates: Coordinates(6.52, 3.37),
    ),
    dropOff: Address(
      'Divine Mercy Lodge, Hilltop',
      coordinates: Coordinates(6.51, 3.36),
    ),
    description: 'Burger + fries + drink combo',
    status: OrderStatus.confirmed,
    price: 2500,
    rider: RiderData(
      id: 'id',
      name: 'John Doe',
      phone: 'phone',
      imageUrl: 'imageUrl',
    ),
  ),
  Order(
    id: '2',
    type: OrderType.errands,
    pickUp: Address('Chicken Republic', coordinates: Coordinates(6.53, 3.35)),
    dropOff: Address(
      '34 Orungle Street, Opposite Kings Close. Ikeja',
      coordinates: Coordinates(6.50, 3.34),
    ),
    description:
        'Pick up cleaned suits at 34 Orungle Street, Opposite Kings Close. Ikeja',
    status: OrderStatus.cancelled,
    price: 1500,
    rider: null,
  ),
  Order(
    id: '2',
    type: OrderType.errands,
    pickUp: Address('Chicken Republic', coordinates: Coordinates(6.53, 3.35)),
    dropOff: Address(
      '34 Orungle Street, Opposite Kings Close. Ikeja',
      coordinates: Coordinates(6.50, 3.34),
    ),
    description: 'Pick up cleaned suits',
    status: OrderStatus.pending,
    price: 1500,
    rider: null,
  ),
  Order(
    id: '2',
    type: OrderType.errands,
    pickUp: Address('Chicken Republic', coordinates: Coordinates(6.53, 3.35)),
    dropOff: Address(
      '34 Orungle Street, Opposite Kings Close. Ikeja',
      coordinates: Coordinates(6.50, 3.34),
    ),
    description:
        'Pick up Chicken Republic at 34 Orungle Street, Opposite Kings Close. Ikeja.\nRepublic at 34 Orungle Street, Opposite Kings Close. Ikeja',
    status: OrderStatus.delivered,
    price: 1500,
    rider: null,
  ),
  Order(
    id: '2',
    type: OrderType.errands,
    pickUp: Address('Chicken Republic', coordinates: Coordinates(6.53, 3.35)),
    dropOff: Address(
      '34 Orungle Street, Opposite Kings Close. Ikeja',
      coordinates: Coordinates(6.50, 3.34),
    ),
    description: 'Pick up cleaned suits',
    status: OrderStatus.enRoute,
    price: 1500,
    rider: null,
  ),
  Order(
    id: '2',
    type: OrderType.errands,
    pickUp: Address('Chicken Republic', coordinates: Coordinates(6.53, 3.35)),
    dropOff: Address(
      '34 Orungle Street, Opposite Kings Close. Ikeja',
      coordinates: Coordinates(6.50, 3.34),
    ),
    description: 'Pick up cleaned suits',
    status: OrderStatus.confirmed,
    price: 1500,
    rider: null,
  ),
  Order(
    id: '2',
    type: OrderType.errands,
    pickUp: Address('Chicken Republic', coordinates: Coordinates(6.53, 3.35)),
    dropOff: Address(
      '34 Orungle Street, Opposite Kings Close. Ikeja',
      coordinates: Coordinates(6.50, 3.34),
    ),
    description: 'Pick up cleaned suits',
    status: OrderStatus.cancelled,
    price: 1500,
    rider: null,
  ),
  Order(
    id: '2',
    type: OrderType.errands,
    pickUp: Address('Chicken Republic', coordinates: Coordinates(6.53, 3.35)),
    dropOff: Address(
      '34 Orungle Street, Opposite Kings Close. Ikeja',
      coordinates: Coordinates(6.50, 3.34),
    ),
    description: 'Pick up cleaned suits',
    status: OrderStatus.enRoute,
    price: 1500,
    rider: null,
  ),
];

class OrdersTab extends ConsumerStatefulWidget {
  const OrdersTab({super.key});

  @override
  ConsumerState<OrdersTab> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersTab> {
  @override
  Widget build(BuildContext context) {
    bool hasActiveRider = true;
    final ongoing = orders.where((o) => !o.status.isFinal).toList();
    final history = orders.where((o) => o.status.isFinal).toList();
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Builder(
          builder: (context) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  stretch: true,
                  toolbarHeight: 0,
                  expandedHeight: 200,
                  stretchTriggerOffset: 80,
                  onStretchTrigger: () async {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Tap on map to enter full screen"),
                        ),
                      );
                    });
                  },
                  flexibleSpace:
                      hasActiveRider
                          ? FlexibleSpaceBar(
                            collapseMode: CollapseMode.parallax,
                            background: RiderOnTheWayCard(
                              rider: orders[0].rider!,
                              eta: '20 mins',
                            ),
                          )
                          : null,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(kToolbarHeight),
                    child: ColoredBox(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: TabBar(
                        tabs: const [
                          Tab(text: 'Ongoing'),
                          Tab(text: 'History'),
                        ],
                        indicatorColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                ListenableBuilder(
                  listenable: DefaultTabController.of(context),
                  builder: (context, _) {
                    return switch (DefaultTabController.of(context).index) {
                      0 => _OrdersSliverList(orders: ongoing),
                      1 => _OrdersSliverList(orders: history),
                      _ => throw FlutterError('More tabs than Tabviews'),
                    };
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OrdersSliverList extends StatelessWidget {
  const _OrdersSliverList({required this.orders});
  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OrderCard(order: orders[index]),
          );
        }, childCount: orders.length),
      ),
    );
  }
}

class RiderOnTheWayCard extends StatelessWidget {
  const RiderOnTheWayCard({super.key, required this.rider, required this.eta});

  final RiderData rider;
  final String eta;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: () => RiderTrackerPageRoute(rider).push(context),
          child: AbsorbPointer(child: RiderTrackerMapWidget(rider: rider)),
        ),
        Positioned(
          left: 8,
          right: 8,
          bottom: kToolbarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withAlpha(180),
                visualDensity: const VisualDensity(vertical: -3),
                label: Row(
                  children: [
                    Icon(
                      Icons.navigation,
                      size: 14,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tracking Rider',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
