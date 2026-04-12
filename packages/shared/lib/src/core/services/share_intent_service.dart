import 'dart:async';
import 'package:adapters/logger/logger.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';

/// Service to handle incoming sharing intents (text, files) from outside the app.
class ShareIntentService {
  ShareIntentService({required UserStore userStore}) : _userStore = userStore;

  final UserStore _userStore;
  late StreamSubscription<void> _intentDataStreamSubscription;
  GoRouter? _router;

  /// Initializes the sharing intent listener.
  Future<void> init(GoRouter router) {
    _router = router;

    // For sharing coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = FlutterSharingIntent.instance
        .getMediaStream()
        .listen(
          _handleSharedMedia,
          onError: (Object err) {
            appLogger.error('[ShareIntentService] Stream Error: $err');
          },
        );

    // For sharing coming from outside the app while the app is closed
    return FlutterSharingIntent.instance.getInitialSharing().then(
      _handleSharedMedia,
    );
  }

  Future<void> _handleSharedMedia(List<SharedFile> value) async {
    if (value.isEmpty) return;

    final media = value.first;
    // We only care about text for now (for Order Parsing)
    if (media.type != SharedMediaType.TEXT) return;

    final text = media.value ?? '';
    if (text.trim().isEmpty) return;

    appLogger.debug('[ShareIntentService] Received shared content: $text');

    // Check if the user is a Dispatcher
    final user = await _userStore.getUser();
    if (user != null && user.role == UserRole.DISPATCHER) {
      // Check if the router is ready
      if (_router == null) return;

      // Push to the AI Parse route so it's on top of the stack.
      // This allows the user to pop back to whichever dispatcher page they were on.
      _router!.go(ModuleRoutePaths.dispatcherParseText, extra: text);
    }
  }

  void dispose() {
    _intentDataStreamSubscription.cancel();
  }
}
