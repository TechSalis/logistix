import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:implicitly_animated_list/implicitly_animated_list.dart';
import 'package:logistix/app/domain/entities/rider_data.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/core/utils/router.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';
import 'package:logistix/features/orders/presentation/widgets/order_card.dart';
import 'package:logistix/features/rider/presentation/widgets/rider_card_small.dart';
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
    status: OrderStatus.accepted,
    price: 2500,
    rider: RiderData(id: 'id', name: 'John Doe', phone: 'phone', imageUrl: ''),
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
    id: '3',
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
    id: '4',
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
    id: '5',
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
    id: '6',
    type: OrderType.errands,
    pickUp: Address('Chicken Republic', coordinates: Coordinates(6.53, 3.35)),
    dropOff: Address(
      '34 Orungle Street, Opposite Kings Close. Ikeja',
      coordinates: Coordinates(6.50, 3.34),
    ),
    description: 'Pick up cleaned suits',
    status: OrderStatus.accepted,
    price: 1500,
    rider: null,
  ),
  Order(
    id: '7',
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
    id: '28',
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

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                  expandedHeight: hasActiveRider ? .3.sh : null,
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
                            background: _RiderTrackerCard(
                              rider: orders[0].rider!,
                              eta: '20 mins',
                            ),
                          )
                          : null,
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(
                      kToolbarHeight + (hasActiveRider ? 44 : 0),
                    ),
                    child: ColoredBox(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Column(
                        children: [
                          if (hasActiveRider)
                            _TrackingRiderTitleBar(rider: orders[0].rider!),
                          TabBar(
                            tabs: const [
                              Tab(text: 'Ongoing'),
                              Tab(text: 'History'),
                            ],
                            onTap: (value) {},
                            indicatorColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ListenableBuilder(
                  listenable: DefaultTabController.of(context),
                  builder: (context, _) {
                    return _OrdersSliverList(
                      orders: switch (DefaultTabController.of(context).index) {
                        0 => ongoing,
                        1 => history,
                        _ => throw FlutterError('More tabs than Tabviews'),
                      },
                    );
                  },
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 16),
                  sliver: SliverToBoxAdapter(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Show more'),
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

  @override
  bool get wantKeepAlive => true;
}

class _OrdersSliverList extends StatelessWidget {
  const _OrdersSliverList({required this.orders});
  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      sliver: SliverImplicitlyAnimatedList(
        itemData: orders,
        itemBuilder: (context, item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: OrderCard(
              order: item,
              onPopupSelected: (event) {
                switch (event) {
                  case OrderPopupEvent.cancel:
                    break;
                  case OrderPopupEvent.reorder:
                    break;
                }
              },
            ),
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
        padding: padding_H16_V8,
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => ChatPageRoute(rider).push(context),
                child: UserProfileGroup(user: rider),
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
    return Stack(
      children: [
        GestureDetector(
          onTap: () => RiderTrackerPageRoute(rider).push(context),
          child: AbsorbPointer(child: RiderTrackerMapWidget(rider: rider)),
        ),
      ],
    );
  }
}
