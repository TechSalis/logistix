import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logistix/core/constants/colors.dart';
import 'package:logistix/core/presentation/widgets/bottomsheet_container.dart';
import 'package:logistix/features/quick_actions/presentation/pages/food_dialog.dart';
import 'package:logistix/features/home/presentation/widgets/map_section.dart';
import 'package:logistix/features/home/presentation/widgets/quick_action_widget.dart';
import 'package:logistix/features/quick_actions/presentation/quick_actions_enum.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Builder(
        builder: (context) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Column(
                children: [
                  Expanded(flex: 3, child: MapSection()),
                  Container(
                    height: 200.h - 24,
                    color:
                        Theme.of(
                          context,
                        ).bottomNavigationBarTheme.backgroundColor!,
                  ),
                ],
              ),
              SizedBox(
                height: 220.h,
                child: BottomsheetContainer(
                  borderRadius: const BorderRadius.all(Radius.circular(24)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        SizedBox(height: 8.h),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Quick Actions',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        SizedBox(
                          height: 68.h,
                          child: Material(
                            type: MaterialType.transparency,
                            child: IconTheme(
                              data: IconThemeData(size: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children:
                                    [
                                      QuickActionWidget(
                                        action: QuickAction.food,
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            showDragHandle: true,
                                            isScrollControlled: true,
                                            builder: (context) {
                                              return FoodQASection();
                                            },
                                          );
                                        },
                                      ),
                                      QuickActionWidget(
                                        action: QuickAction.groceries,
                                        onTap: () {},
                                      ),
                                      QuickActionWidget(
                                        action: QuickAction.errands,
                                        onTap: () {},
                                      ),
                                      QuickActionWidget(
                                        action: QuickAction.repeatOrder,
                                        onTap: () {},
                                      ),
                                    ].map((e) => Expanded(child: e)).toList(),
                              ),
                            ),
                          ),
                        ),
                        Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primarySwatch,
                                ),
                                label: Text('Find Rider'),
                                icon: Icon(Icons.add_call),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                label: Text('New Delivery'),
                                icon: Icon(Icons.library_add),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        useLegacyColorScheme: false,
        type: BottomNavigationBarType.fixed,
        onTap: (value) {},
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining),
            label: 'Orders',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person_2), label: 'Profile'),
        ],
      ),
    );
  }
}
