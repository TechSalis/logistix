import 'package:dispatcher/src/domain/usecases/manage_dispatcher_session_usecase.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

/// Widget that initializes and manages the dispatcher session
class DispatcherSessionProvider extends StatefulWidget {
  const DispatcherSessionProvider({
    required this.sessionManager,
    required this.userStore,
    required this.child,
    super.key,
  });

  final DispatcherSessionManager sessionManager;
  final UserStore userStore;
  final Widget child;

  @override
  State<DispatcherSessionProvider> createState() =>
      _DispatcherSessionProviderState();
}

class _DispatcherSessionProviderState
    extends State<DispatcherSessionProvider> {
  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    final user = await widget.userStore.getUser();
    if (!mounted || user?.companyId == null) return;

    await widget.sessionManager.start(companyId: user!.companyId!);
  }

  @override
  void dispose() {
    widget.sessionManager.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
