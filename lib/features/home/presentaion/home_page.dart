import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logistix/core/presentation/widgets/bottomsheet_container.dart';
import 'package:logistix/features/delivery/presentation/pages/new_delivery_page.dart';
import 'package:logistix/features/home/application/navigation_bar_rp.dart';
import 'package:logistix/features/notifications/application/notification_manager.dart';
import 'package:logistix/features/notifications/presentation/widgets/notification_widget.dart';
import 'package:logistix/features/rider/domain/entities/rider.dart';
import 'package:logistix/features/rider/find_rider/logic/find_rider_rp.dart';
import 'package:logistix/features/rider/find_rider/widgets/find_rider_dialog.dart';
import 'package:logistix/features/quick_actions/presentation/pages/food_dialog.dart';
import 'package:logistix/features/map/presentation/widgets/map_view.dart';
import 'package:logistix/features/quick_actions/presentation/widgets/quick_action_widget.dart';
import 'package:logistix/features/quick_actions/domain/quick_actions_types.dart';
import 'package:overlay_support/overlay_support.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Column(
            children: [
              Expanded(flex: 3, child: MapView()),
              Container(
                height: 210.h - 34,
                color:
                    Theme.of(context).bottomNavigationBarTheme.backgroundColor!,
              ),
            ],
          ),
          SizedBox(
            height: 210.h,
            child: BottomsheetContainer(
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(height: 64.h, child: const _QuickActions()),
                    Spacer(),
                    const _DeliveryButtons(),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ),
          // SafeArea(
          //   child: Align(
          //     alignment: Alignment.topRight,
          //     child: Padding(
          //       padding: const EdgeInsets.fromLTRB(0, 4, 8, 0),
          //       child: IconButton(
          //         onPressed: () {},
          //         icon: Badge.count(count: 3, child: Icon(Icons.notifications)),
          //       ),
          //     ),
          //   ),
          // ),
          if (kDebugMode)
            Center(
              child: ElevatedButton(
                onPressed: () {
                  NotificationManager.showPermanentNotification((context) {
                    return Consumer(
                      builder: (context, ref, child) {
                        return QARiderNotificationWidget(
                          action: QuickAction.food,
                          rider: Rider(
                            id: 'id',
                            name: 'Abdul Dromonka',
                            company: 'WiMart Logistics',
                            rating: 4,
                          ),
                          onMore: () {
                            ref.read(navBarIndexProvider.notifier).state = 1;
                          },
                          onCancel: () {
                            OverlaySupportEntry.of(context)?.dismiss();
                          },
                        );
                      },
                    );
                  });
                },
                child: Text('Debug Button'),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _NavBar(),
    );
  }
}

class _NavBar extends ConsumerWidget {
  const _NavBar();

  @override
  Widget build(BuildContext context, ref) {
    return BottomNavigationBar(
      elevation: 0,
      useLegacyColorScheme: false,
      type: BottomNavigationBarType.fixed,
      onTap: (value) {
        ref.read(navBarIndexProvider.notifier).state = value;
      },
      currentIndex: ref.watch(navBarIndexProvider),
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.moped_rounded),
          label: 'Orders',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person_2), label: 'Profile'),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: IconTheme(
        data: IconThemeData(size: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              [
                QuickActionWidget(
                  action: QuickAction.food,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      isScrollControlled: true,
                      builder: (context) => SubmitFoodQADialog(),
                    );
                  },
                ),
                QuickActionWidget(action: QuickAction.groceries, onTap: () {}),
                QuickActionWidget(action: QuickAction.errands, onTap: () {}),
                QuickActionWidget(
                  action: QuickAction.repeatOrder,
                  onTap: () {},
                ),
              ].map((e) => Expanded(child: e)).toList(),
        ),
      ),
    );
  }
}

class _DeliveryButtons extends ConsumerWidget {
  const _DeliveryButtons();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              final confirmed = await showDialog(
                context: context,
                builder: (_) => FindRiderDialog(),
              );

              if (confirmed != null) {
                Future.delayed(Durations.medium3, () {
                  ref.invalidate(findRiderProvider);
                });
                // Start rider tracking, next UI page, etc.
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.tertiary,
            ),
            label: Text('Find Rider'),
            icon: const Icon(Icons.motorcycle),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => NewDeliveryPage()),
              );
            },
            label: Text('New Delivery'),
            icon: Icon(Icons.library_add),
          ),
        ),
      ],
    );
  }
}
