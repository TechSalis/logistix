import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/account/application/account_rp.dart';
import 'package:logistix/features/auth/application/logic/auth_rp.dart';
import 'package:logistix/features/auth/infrastructure/repository/auth_local_store.dart';
import 'package:logistix/features/notifications/application/notification_service.dart';
import 'package:logistix/features/permission/application/permission_rp.dart';
import 'package:logistix/features/permission/domain/entities/permission_data.dart';

class AppProviderScope extends StatefulWidget {
  const AppProviderScope({super.key, required this.child});
  final Widget child;

  @override
  State<AppProviderScope> createState() => _AppProviderScopeState();
}

class _AppProviderScopeState extends State<AppProviderScope> {
  UniqueKey _providerScopeKey = UniqueKey();
  WidgetRef? postProviderRef;

  ProviderSubscription<bool>? notifyListener;

  @override
  void initState() {
    // The postProviderRef is set in the build method.
    // Therefore we need to use a postFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListener = postProviderRef?.listenManual(
        permissionProvider(PermissionData.notifications).select((value) {
          return value.isGranted ?? false;
        }),
        (p, isGranted) {
          if (isGranted) {
            NotificationService.setup();
            notifyListener?.close();
            notifyListener = null;
          } else {}
        },
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    notifyListener?.close();
    notifyListener = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      key: _providerScopeKey,
      child: Consumer(
        builder: (_, ref, _) {
          postProviderRef = ref;
          ref.listen(authProvider, (p, auth) {
            if (auth is AuthUnknownState) return;
            final canNotify =
                ref
                    .read(permissionProvider(PermissionData.notifications))
                    .isGranted;
            if (auth is AuthLoggedOutState) {
              AuthLocalStore.instance.clear();
              if (canNotify == true) {
                ref.read(accountProvider.notifier).clearFCM();
              }
              setState(() => _providerScopeKey = UniqueKey());
            } else if (auth is AuthLoggedInState) {
              AuthLocalStore.instance.saveUser(auth.user);
              if (canNotify == true) {
                ref.read(accountProvider.notifier).uploadFCM();
              }
            }
          });
          return widget.child;
        },
      ),
    );
  }
}
