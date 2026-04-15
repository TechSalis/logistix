// ignore_for_file: constant_identifier_names
import 'dart:async';
import 'dart:math';
import 'package:bootstrap/interfaces/connectivity/connectivity.dart';
import 'package:bootstrap/interfaces/logger/logger.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared/src/core/network/graphql_service.dart';

enum SyncConnectionState { DISCONNECTED, CONNECTING, SUBSCRIBED, RECONNECTING }

/// A wrapper around robust GraphQL subscriptions with automatic catch-up on reconnection.
///
/// Refactored to support multiple concurrent subscriptions on a single manager instance.
/// This allows data sources to manage multiple real-time streams (e.g., Orders and Riders)
/// while sharing the same connectivity lifecycle and reconnection logic.
class SyncManager {
  SyncManager(this._graphqlService, this._connectivity, {this.logger}) {
    // Listen for network restoration to trigger catch-up syncs for all active subscriptions
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      connected,
    ) {
      if (connected && _state == SyncConnectionState.SUBSCRIBED) {
        logger?.info(
          'SyncManager: Network restored, triggering catch-up for all subscriptions',
        );
        _triggerAllCatchUps();
      }
    });
  }

  final GraphQLService _graphqlService;
  final IConnectivityService _connectivity;
  final Logger? logger;

  SyncConnectionState _state = SyncConnectionState.DISCONNECTED;
  final _stateController = StreamController<SyncConnectionState>.broadcast();

  // Track all active subscriptions and their listeners
  final List<_SyncSubscription> _subscriptions = [];
  final List<StreamSubscription<QueryResult<Map<String, dynamic>>>> _listeners =
      [];
  StreamSubscription<bool>? _connectivitySubscription;

  // Parameters for reconnection backoff
  int _retryCount = 0;
  static const int _maxRetries = 10;
  static const Duration _baseDelay = Duration(seconds: 2);

  SyncConnectionState get state => _state;
  Stream<SyncConnectionState> get stateStream => _stateController.stream;

  /// Starts a robust sync using GraphQL subscriptions with automatic catch-up on reconnection.
  ///
  /// Supports multiple calls; each call adds a new subscription to be managed by this instance.
  Future<void> startSubscription({
    required String subscriptionDocument,
    required Future<void> Function(Map<String, dynamic> data) onData,
    Map<String, dynamic>? variables,
    Future<void> Function()? onSync,
  }) async {
    final sub = _SyncSubscription(
      document: subscriptionDocument,
      onData: onData,
      variables: variables,
      onSync: onSync,
    );

    _subscriptions.add(sub);
    await _subscribeOne(sub);
  }

  Future<void> _subscribeOne(_SyncSubscription sub) async {
    _setState(
      _retryCount > 0
          ? SyncConnectionState.RECONNECTING
          : SyncConnectionState.CONNECTING,
    );

    // Initial sync for this specific subscription
    try {
      if (sub.onSync != null) {
        await sub.onSync!();
      }
    } catch (e) {
      logger?.error('SyncManager Individual Catch-up Error: $e');
    }

    final listener = _graphqlService
        .subscribe<Map<String, dynamic>>(sub.document, variables: sub.variables)
        .listen(
          (result) async {
            if (result.hasException) {
              logger?.error('SyncManager Error: ${result.exception}');
              _handleGlobalFailure();
              return;
            }

            _setState(SyncConnectionState.SUBSCRIBED);
            _retryCount = 0;

            if (result.data != null) {
              await sub.onData(result.data!);
            }
          },
          onError: (Object error) {
            logger?.error('SyncManager Stream Error: $error');
            _handleGlobalFailure();
          },
          onDone: () {
            logger?.warn('SyncManager Stream Closed');
            _handleGlobalFailure();
          },
        );

    _listeners.add(listener);
  }

  Future<void> _subscribeAll() async {
    await _cancelAllListeners();

    _setState(
      _retryCount > 0
          ? SyncConnectionState.RECONNECTING
          : SyncConnectionState.CONNECTING,
    );

    // Trigger catch-up for all before resubscribing
    await _triggerAllCatchUps();

    for (final sub in _subscriptions) {
      final listener = _graphqlService
          .subscribe<Map<String, dynamic>>(
            sub.document,
            variables: sub.variables,
          )
          .listen(
            (result) async {
              if (result.hasException) {
                logger?.error('SyncManager Error: ${result.exception}');
                _handleGlobalFailure();
                return;
              }

              _setState(SyncConnectionState.SUBSCRIBED);
              _retryCount = 0;

              if (result.data != null) {
                await sub.onData(result.data!);
              }
            },
            onError: (Object error) {
              logger?.error('SyncManager Stream Error: $error');
              _handleGlobalFailure();
            },
            onDone: () {
              logger?.warn('SyncManager Stream Closed');
              _handleGlobalFailure();
            },
          );
      _listeners.add(listener);
    }
  }

  Future<void> _triggerAllCatchUps() async {
    try {
      logger?.info(
        'SyncManager: Performing catch-up for ${_subscriptions.length} subscriptions',
      );
      await Future.wait(
        _subscriptions.map((s) => s.onSync?.call() ?? Future<void>.value()),
      );
      _retryCount = 0; // Reset on successful sync
    } catch (e) {
      logger?.error('SyncManager Global Catch-up Error: $e');
    }
  }

  void _handleGlobalFailure() {
    unawaited(_cancelAllListeners());

    if (_retryCount >= _maxRetries) {
      logger?.error(
        'SyncManager: Max retries reached ($_maxRetries). Stopping.',
      );
      _setState(SyncConnectionState.DISCONNECTED);
      return;
    }

    _retryCount++;
    final delayMs = (_baseDelay.inMilliseconds * pow(2, _retryCount - 1))
        .toInt();
    final jitter = Random().nextInt(1000);
    final delay = Duration(milliseconds: delayMs + jitter);

    logger?.info(
      'SyncManager: Global retry in ${delay.inSeconds}s (Attempt $_retryCount/$_maxRetries)',
    );
    _setState(SyncConnectionState.RECONNECTING);

    Timer(delay, () {
      if (_state == SyncConnectionState.DISCONNECTED) return;
      _subscribeAll();
    });
  }

  Future<void> _cancelAllListeners() async {
    await Future.wait(_listeners.map((listener) => listener.cancel()));
    _listeners.clear();
  }

  void _setState(SyncConnectionState newState) {
    if (_state != newState) {
      logger?.debug('SyncManager State: $newState');
      _state = newState;
      if (!_stateController.isClosed) {
        _stateController.add(newState);
      }
    }
  }

  void stop() {
    unawaited(_cancelAllListeners());
    _setState(SyncConnectionState.DISCONNECTED);
  }

  void dispose() {
    stop();
    _connectivitySubscription?.cancel();
    _stateController.close();
    _subscriptions.clear();
  }
}

/// Helper container for a single managed subscription
class _SyncSubscription {
  _SyncSubscription({
    required this.document,
    required this.onData,
    this.variables,
    this.onSync,
  });

  final String document;
  final Map<String, dynamic>? variables;
  final Future<void> Function(Map<String, dynamic> data) onData;
  final Future<void> Function()? onSync;
}
