import 'package:customer/src/domain/usecases/manage_customer_session_usecase.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

/// Widget that initializes and manages the customer session
class CustomerSessionProvider extends StatefulWidget {
  const CustomerSessionProvider({
    required this.sessionManager,
    required this.userStore,
    required this.child,
    super.key,
  });

  final CustomerSessionManager sessionManager;
  final UserStore userStore;
  final Widget child;

  @override
  State<CustomerSessionProvider> createState() =>
      _CustomerSessionProviderState();
}

class _CustomerSessionProviderState
    extends State<CustomerSessionProvider> {
  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    final user = await widget.userStore.getUser();
    if (!mounted || user?.id == null) return;

    await widget.sessionManager.start(userId: user!.id);
  }

  @override
  void dispose() {
    widget.sessionManager.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
