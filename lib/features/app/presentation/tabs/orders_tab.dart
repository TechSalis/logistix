// lib/features/orders/presentation/pages/orders_page.dart

import 'package:flutter/material.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';
import 'package:logistix/features/orders/presentation/widgets/order_card.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/quick_actions/presentation/quick_actions_types.dart';
import 'package:logistix/features/rider/domain/entities/rider.dart';
import 'package:logistix/features/rider/presentation/widgets/rider_on_the_way_widget.dart';

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    const mockOrders = [
      Order(
        id: '1',
        type: QuickActionType.food,
        pickUp: Address(
          'Burger Place. Hilltop, Burger Place. Hilltop',
          coordinates: Coordinates(6.52, 3.37),
        ),
        dropOff: Address(
          'Divine Mercy Lodge, Hilltop. Divine Mercy Lodge, Hilltop',
          coordinates: Coordinates(6.51, 3.36),
        ),
        description: 'Burger + fries + drink combo',
        status: OrderStatus.confirmed,
        price: 2500,
        rider: Rider(id: '1', name: 'John Doe', rating: 4.7, company: 'RiderX'),
      ),
      Order(
        id: '2',
        type: QuickActionType.errands,
        pickUp: Address(
          'Chicken Republic, Behind Tanker Clode. After BigHouse. Maryland',
          coordinates: Coordinates(6.53, 3.35),
        ),
        dropOff: Address(
          '34 Orungle Street, Opposite Kings Close. Ikeja',
          coordinates: Coordinates(6.50, 3.34),
        ),
        description: 'Pick up cleaned suits ',
        status: OrderStatus.pending,
        price: 1500,
        rider: null,
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          ),
          // Rider on the way card
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverToBoxAdapter(
              child: RiderOnTheWayCard(
                rider: mockOrders[0].rider!,
                eta: '20 min',
              ),
            ),
          ),
          const SliverAppBar(
            title: Text('Your Orders'),
            pinned: true,
            toolbarHeight: 20,
          ),
          // Order cards
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            sliver: SliverList.builder(
              itemCount: mockOrders.length,
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: true,
              itemBuilder: (_, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: OrderCard(order: mockOrders[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
