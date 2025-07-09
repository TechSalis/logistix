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

class _NavBarState extends ConsumerState<_NavBar> with RestorationMixin {
  final _counter = RestorableInt(0);

  @override
  String? get restorationId => 'home-nav';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_counter, 'tab-index');
  }

  @override
  void initState() {
    _counter.addListener(() {
      ref.read(navBarIndexProvider.notifier).state = _counter.value;
    });
    super.initState();
  }

  @override
  void dispose() {
    _counter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(navBarIndexProvider, (p, n) => _counter.value = n);
    return BottomNavigationBar(
      // elevation: 2,
      useLegacyColorScheme: false,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      currentIndex: ref.watch(navBarIndexProvider),
      onTap: (value) => _counter.value = value,
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
