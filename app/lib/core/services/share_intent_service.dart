import 'dart:async';
import 'package:adapters/logger/logger.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';

/// Service to handle incoming shared content (text/media) from external apps.
class ShareIntentService {
  ShareIntentService({required UserStore userStore}) : _userStore = userStore;
  final UserStore _userStore;

  StreamSubscription<List<SharedFile>>? _intentSubscription;

  /// Starts listening for sharing intents.
  Future<void> init(GoRouter router) async {
    // 1. Check for initial intent (app opened from shared content)
    await FlutterSharingIntent.instance.getInitialSharing().then((media) {
      if (media.isNotEmpty) {
        _handleMedia(router, media[0]);
      }
    });

    // 2. Listen to future intents (while app is in foreground/background)
    _intentSubscription = FlutterSharingIntent.instance.getMediaStream().listen(
      (media) {
        if (media.isNotEmpty) {
          _handleMedia(router, media[0]);
        }
      },
      onError: (Object err) => appLogger.error('Share Intent Error: $err'),
    );
  }

  Future<void> _handleMedia(GoRouter router, SharedFile media) async {
    // We only care about text for now (for Order Parsing)
    if (media.type != SharedMediaType.TEXT) return;

    final text = media.value ?? '';
    if (text.trim().isEmpty) return;

    // Check if the user is a Dispatcher
    final user = await _userStore.getUser();
    if (user != null && user.role == UserRole.dispatcher) {
      // Push to the AI Parse route so it's on top of the stack.
      // This allows the user to pop back to whichever dispatcher page they were on.
      router.go(ModuleRoutePaths.dispatcherParseText, extra: text);
    }
  }

  void dispose() => _intentSubscription?.cancel();
}
