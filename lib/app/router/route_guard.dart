import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

typedef RouteStateCallback<T> = T Function(BuildContext, GoRouterState);

class RouteGuardsBuilder {
  final List<RouteGuard> guards;
  const RouteGuardsBuilder(this.guards);

  FutureOr<String?> call(BuildContext context, GoRouterState state) {
    for (final guard in guards) {
      final result = guard.condition(context, state);
      if (result != null && !result) {
        if (guard.onFail != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => guard.onFail!());
        }
        return guard.redirect;
      }
    }
    return null;
  }
}

class RouteGuard {
  final RouteStateCallback<bool?> condition;
  final String redirect;
  final VoidCallback? onFail;

  const RouteGuard({
    required this.condition,
    required this.redirect,
    this.onFail,
  });
}

class PageRoutesGuard extends RouteGuard {
  final List<String> routes;

  PageRoutesGuard({
    required super.redirect,
    super.onFail,
    required bool Function(BuildContext, GoRouterState) guardCondition,
    required this.routes,
  }) : super(
         condition: (BuildContext context, GoRouterState state) {
           if (routes.contains(state.matchedLocation)) {
             return guardCondition(context, state);
           }
           return null;
         },
       );
}
