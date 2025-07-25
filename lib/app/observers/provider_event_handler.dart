import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/account/application/account_rp.dart';
import 'package:logistix/features/auth/application/logic/auth_rp.dart';
import 'package:logistix/features/auth/infrastructure/repository/auth_local_store.dart';

class AppProviderScope extends StatefulWidget {
  const AppProviderScope({super.key, required this.child});
  final Widget child;

  @override
  State<AppProviderScope> createState() => _AppProviderScopeState();
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
            switch (n) {
              case AuthLoggedOutState _:
                AuthLocalStore.instance.clear();
                ref.read(accountProvider.notifier).clearFCM();
                setState(() => _providerScopeKey = UniqueKey());
              case AuthLoggedInState _:
                AuthLocalStore.instance.saveUser(n.user);
                ref.read(accountProvider.notifier).uploadFCM();
              case AuthUnknownState _:
            }
          });
          return child!;
        },
        child: widget.child,
      ),
    );
  }
}
