import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/app/application/navigation_bar_rp.dart';
import 'package:logistix/app/presentation/tabs/home_tab.dart';
// import 'package:logistix/features/app/presentation/tabs/orders_tab%20copy%203.dart';
// import 'package:logistix/features/app/presentation/tabs/orders_tab%20copy.dart';
import 'package:logistix/app/presentation/tabs/orders_tab.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final controller = PageController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(navBarIndexProvider, (p, n) {
      controller.animateToPage(
        n,
        duration: Durations.medium2,
        curve: Curves.easeInOut,
      );
    });
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: PageView(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        children: const [HomeTab(), OrdersTab()],
      ),
      bottomNavigationBar: const _NavBar(),
    );
  }
}

class _NavBar extends ConsumerStatefulWidget {
  const _NavBar();

  @override
  ConsumerState<_NavBar> createState() => _NavBarState();
}

class _NavBarState extends ConsumerState<_NavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      useLegacyColorScheme: false,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      currentIndex: ref.watch(navBarIndexProvider),
      onTap: (value) {
        if (ref.watch(navBarIndexProvider) != value) {
          ref.watch(navBarIndexProvider.notifier).state = value;
        } else {
          final controller = PrimaryScrollController.maybeOf(context);
          if (controller?.hasClients ?? false) {
            controller?.animateTo(
              0,
              duration: kTabScrollDuration,
              curve: Curves.easeInOut,
            );
          }
        }
      },
      items: const [
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
