import 'dart:async';
import 'package:dispatcher/src/features/chat/data/datasources/chat_local_datasource.dart';
import 'package:dispatcher/src/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:dispatcher/src/features/chat/domain/entities/chat_update.dart';
import 'package:dispatcher/src/features/chat/domain/usecases/sync_chat_data_usecase.dart';
import 'package:shared/shared.dart';

/// Manages real-time communication events as a plugin for the SessionCoordinator.
class ChatSessionManager extends SessionComponent {
  ChatSessionManager(
    this._remoteDataSource,
    this._localDataSource,
    this._syncUseCase,
    this._database,
  );

  final ChatRemoteDataSource _remoteDataSource;
  final ChatLocalDataSource _localDataSource;
  final SyncChatDataUseCase _syncUseCase;
  final LogistixDatabase _database;

  // Typing is disabled system-wide to save CPU and reduce network chatter.
  Stream<TypingStatus?> get typingStream => const Stream.empty();

  @override
  String get id => 'chat_feature';

  @override
  Future<void> start() async {
    await _remoteDataSource.subscribeToChat(
      onData: (payload) {
        if ((payload.type == ChatUpdateType.MESSAGE ||
                payload.type == ChatUpdateType.STATUS) &&
            payload.message != null) {
          _localDataSource.cacheMessage(payload.message!);
        }
      },
      onSync: sync,
    );
  }

  @override
  Future<void> sync() async {
    final lastSync = await _database.getLastSyncTime(
      SyncKeys.chatLastSync,
    );
    await _syncUseCase(since: lastSync?.millisecondsSinceEpoch.toDouble());
  }

  @override
  Future<void> stop() async {
    // [DISCONNECTED] _typingController closed and removed to save CPU.
  }
}
