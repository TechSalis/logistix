import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/home/application/navigation_bar_rp.dart';
import 'package:logistix/features/home/presentation/tabs/home_tab.dart';
import 'package:logistix/features/home/presentation/tabs/orders_tab.dart';

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

class _NavBar extends ConsumerWidget {
  const _NavBar();

  @override
  Widget build(BuildContext context, ref) {
    return BottomNavigationBar(
      elevation: 2,
      useLegacyColorScheme: false,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      onTap: (value) {
        ref.read(navBarIndexProvider.notifier).state = value;
      },
      currentIndex: ref.watch(navBarIndexProvider),
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
