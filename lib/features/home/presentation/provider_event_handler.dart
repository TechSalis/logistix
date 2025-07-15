import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/auth/application/logic/auth_rp.dart';

class AppProviderScope extends StatefulWidget {
  const AppProviderScope({super.key, required this.child});
  final Widget child;

  @override
  State<AppProviderScope> createState() =>
      _AppProviderScopeState();
}

class _AppProviderScopeState extends State<AppProviderScope> {
  UniqueKey _providerScopeKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      key: _providerScopeKey,
      child: Consumer(
        builder: (context, ref, child) {
          ref.listen(authProvider, (p, n) {
            if (p is AuthUnknownState || p.runtimeType != n.runtimeType) {
              return;
            }
            switch (n) {
              case AuthLoggedOutState _:
                _providerScopeKey = UniqueKey();
              default:
            }
          });
          return child!;
        },
        child: widget.child,
      ),
    );
  }
}
