import 'package:dispatcher/src/domain/usecases/manage_dispatcher_session_usecase.dart';
import 'package:flutter/material.dart';

/// Widget that initializes and manages the dispatcher session
class DispatcherSessionProvider extends StatefulWidget {
  const DispatcherSessionProvider({
    required this.sessionManager,
    required this.child,
    super.key,
  });

  final DispatcherSessionManager sessionManager;
  final Widget child;

  @override
  State<DispatcherSessionProvider> createState() =>
      _DispatcherSessionProviderState();
}

class _DispatcherSessionProviderState extends State<DispatcherSessionProvider> {
  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    await widget.sessionManager.start();
  }

  @override
  void dispose() {
    widget.sessionManager.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
