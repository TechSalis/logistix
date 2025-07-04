import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix/features/home/presentation/home_page.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

final router = GoRouter(
  observers: [routeObserver],
  routes: [GoRoute(path: '/', builder: (context, state) => const HomePage())],
);
