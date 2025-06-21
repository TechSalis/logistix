import 'package:go_router/go_router.dart';
import 'package:logistix/features/home/presentaion/home_page.dart';
import 'package:logistix/features/notifications/application/navigator_observer.dart';

final router = GoRouter(
  observers: [NotificationsNavigatorObserver()],
  routes: [GoRoute(path: '/', builder: (context, state) => HomePage())],
);
