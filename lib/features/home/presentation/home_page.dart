import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/auth/application/logic/auth_rp.dart';
import 'package:logistix/features/home/application/home_rp.dart';
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
  void initState() {
    if (ref.read(authProvider.notifier).canLoginAnonymously()) {
      ref.read(authProvider.notifier).loginAnonymously();
    }
    if (ref.read(authProvider) is AuthLoggedInState) {
      Future.microtask(ref.read(homeProvider.notifier).fetchOrderPreview);
    }
    super.initState();
  }

  @override
  void dispose() {
    ref.invalidate(homeProvider);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (p, n) {
      if (n is AuthLoggedInState) {
        ref.read(homeProvider.notifier).fetchOrderPreview();
      }
    });
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
        onPageChanged: (value) {
          ref.read(navBarIndexProvider.notifier).state = value;
        },
        // physics: const NeverScrollableScrollPhysics(),
        children: const [HomeTab(), OrdersTab()],
      ),
      bottomNavigationBar: const _NavBar(),
    );
  }
}

class _NavBar extends ConsumerWidget {
  const _NavBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomNavigationBar(
      useLegacyColorScheme: false,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      currentIndex: ref.watch(navBarIndexProvider),
      onTap: (value) {
        if (ref.read(navBarIndexProvider) != value) {
          ref.read(navBarIndexProvider.notifier).state = value;
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
          icon: Icon(Icons.format_list_numbered_sharp),
          label: 'Orders',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chat'),
        // BottomNavigationBarItem(icon: Icon(Icons.person_2), label: 'Profile'),
      ],
    );
  }
}
