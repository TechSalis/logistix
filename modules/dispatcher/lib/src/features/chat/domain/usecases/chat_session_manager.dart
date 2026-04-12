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

  final _typingController = StreamController<TypingStatus?>.broadcast();
  Stream<TypingStatus?> get typingStream => _typingController.stream;

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
        } else if (payload.type == ChatUpdateType.TYPING &&
            payload.typing != null) {
          _typingController.add(
            TypingStatus(
              conversationId: payload.typing!.conversationId,
              isTyping: payload.typing!.isTyping,
              senderId: payload.typing!.senderId,
              senderType: payload.typing!.senderType != null
                  ? SenderType.values.firstWhere(
                      (e) =>
                          e.name == payload.typing!.senderType!.toUpperCase(),
                      orElse: () => SenderType.SYSTEM,
                    )
                  : null,
            ),
          );
        }
      },
      onSync: () async {
        final lastSync = await _database.getLastSyncTime(
          ChatSyncKey.chatLastSync,
        );
        await _syncUseCase(since: lastSync?.millisecondsSinceEpoch.toDouble());
      },
    );
  }

  @override
  Future<void> stop() {
    return _typingController.close();
  }
}
