import 'dart:async';
import 'dart:math';
import 'package:bootstrap/interfaces/logger/logger.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared/src/core/network/graphql_service.dart';

enum SyncConnectionState {
  disconnected,
  connecting,
  subscribed,
  reconnecting,
}

/// A wrapper around a robust GraphQL subscription with automatic catch-up on reconnection.
class SyncManager {
  SyncManager(this._graphqlService, {this.logger});

  final GraphQLService _graphqlService;
  final Logger? logger;

  SyncConnectionState _state = SyncConnectionState.disconnected;
  final _stateController = StreamController<SyncConnectionState>.broadcast();
  StreamSubscription<QueryResult>? _subscriptionListener;

  // Parameters for reconnection
  int _retryCount = 0;
  static const int _maxRetries = 10;
  static const Duration _baseDelay = Duration(seconds: 2);

  SyncConnectionState get state => _state;
  Stream<SyncConnectionState> get stateStream => _stateController.stream;

  /// Starts a robust sync using GraphQL subscriptions with automatic catch-up on reconnection.
  Future<void> startSubscription({
    required String subscriptionDocument,
    required Map<String, dynamic> variables,
    required Future<void> Function(Map<String, dynamic> data) onData,
    Future<void> Function()? onSync,
  }) async {
    if (_state == SyncConnectionState.subscribed) return;

    await _subscribe(
      subscriptionDocument: subscriptionDocument,
      variables: variables,
      onData: onData,
      onSync: onSync,
    );
  }

  Future<void> _subscribe({
    required String subscriptionDocument,
    required Map<String, dynamic> variables,
    required Future<void> Function(Map<String, dynamic> data) onData,
    Future<void> Function()? onSync,
  }) async {
    _setState(_retryCount > 0 ? SyncConnectionState.reconnecting : SyncConnectionState.connecting);

    await _subscriptionListener?.cancel();
    _subscriptionListener = _graphqlService
        .subscribeWithSync(
          subscriptionDocument,
          variables: variables,
          onSync: () async {
            logger?.info('SyncManager: Performing catch-up sync');
            _retryCount = 0; // Reset on successful sync
            await onSync?.call();
          },
        )
        .listen(
          (result) async {
            if (result.hasException) {
              logger?.error('SyncManager Error: ${result.exception}');
              _handleFailure(
                subscriptionDocument: subscriptionDocument,
                variables: variables,
                onData: onData,
                onSync: onSync,
              );
              return;
            }

            _setState(SyncConnectionState.subscribed);
            _retryCount = 0;

            if (result.data != null) {
              await onData(result.data!);
            }
          },
          onError: (Object error) {
            logger?.error('SyncManager Stream Error: $error');
            _handleFailure(
              subscriptionDocument: subscriptionDocument,
              variables: variables,
              onData: onData,
              onSync: onSync,
            );
          },
          onDone: () {
            logger?.warn('SyncManager Stream Closed');
            _handleFailure(
              subscriptionDocument: subscriptionDocument,
              variables: variables,
              onData: onData,
              onSync: onSync,
            );
          },
        );
  }

  void _handleFailure({
    required String subscriptionDocument,
    required Map<String, dynamic> variables,
    required Future<void> Function(Map<String, dynamic> data) onData,
    Future<void> Function()? onSync,
  }) {
    unawaited(_subscriptionListener?.cancel());
    _subscriptionListener = null;

    if (_retryCount >= _maxRetries) {
      logger?.error('SyncManager: Max retries reached ($_maxRetries). Stopping.');
      _setState(SyncConnectionState.disconnected);
      return;
    }

    _retryCount++;
    // Exponential backoff: base * 2^retryCount + jitter
    final delayMs = (_baseDelay.inMilliseconds * pow(2, _retryCount - 1)).toInt();
    final jitter = Random().nextInt(1000);
    final delay = Duration(milliseconds: delayMs + jitter);

    logger?.info('SyncManager: Retrying in ${delay.inSeconds}s (Attempt $_retryCount/$_maxRetries)');
    _setState(SyncConnectionState.reconnecting);

    Timer(delay, () {
      if (_state == SyncConnectionState.disconnected) return; // Stopped manually
      _subscribe(
        subscriptionDocument: subscriptionDocument,
        variables: variables,
        onData: onData,
        onSync: onSync,
      );
    });
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
    unawaited(_subscriptionListener?.cancel());
    _subscriptionListener = null;
    _setState(SyncConnectionState.disconnected);
  }

  void dispose() {
    stop();
    _stateController.close();
  }
}
