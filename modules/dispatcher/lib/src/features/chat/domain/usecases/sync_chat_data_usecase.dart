import 'package:bootstrap/interfaces/store/store.dart';
import 'package:dispatcher/src/features/chat/data/datasources/chat_local_datasource.dart';
import 'package:dispatcher/src/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:dispatcher/src/features/chat/data/dtos/chat_sync_request.dart';
import 'package:dispatcher/src/features/chat/data/mappers/chat_mapper.dart';
import 'package:shared/shared.dart';

/// Performs a full catch-up sync for the Chat module.
/// 
/// Decoupled from the main dispatcher sync to allow independent scaling,
/// separate polling intervals, and easier maintenance of messaging logic.
class SyncChatDataUseCase {
  SyncChatDataUseCase({
    required ChatRemoteDataSource remoteDataSource,
    required ChatLocalDataSource localDataSource,
    required ChatDao chatDao,
    required LogistixDatabase database,
    required UserStore userStore,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _chatDao = chatDao,
       _database = database,
       _userStore = userStore;

  final ChatRemoteDataSource _remoteDataSource;
  final ChatLocalDataSource _localDataSource;
  final ChatDao _chatDao;
  final LogistixDatabase _database;
  final UserStore _userStore;

  Future<void> call({double? since, int limit = 100}) async {
    var offset = 0;
    var hasMore = true;
    DateTime? completionTime;
    final companyId = _userStore.user?.companyId ?? '';

    while (hasMore) {
      final syncDto = await _remoteDataSource.syncData(
        ChatSyncRequest(
          since: since, limit: limit, offset: offset,
        ),
      );

      completionTime = DateTime.fromMillisecondsSinceEpoch(syncDto.lastUpdated);

      await _database.transaction(() async {
        await Future.wait([
          if (syncDto.conversations.isNotEmpty)
            Future.wait(
              syncDto.conversations.map(
                (c) =>
                    _chatDao.upsertConversation(c.toDriftCompanion(companyId)),
              ),
            ),
          if (syncDto.deletedMessageIds.isNotEmpty)
            _chatDao.softDeleteMessages(syncDto.deletedMessageIds),
        ]);
      });

      if (syncDto.conversations.length < limit) {
        hasMore = false;
      } else {
        offset += limit;
      }
    }

    // Update Sync Time specifically for Chat
    if (completionTime != null) {
      await _database.updateLastSyncTime(
        SyncKeys.chatLastSync,
        completionTime,
        null,
      );
    }
  }
}

/// Extension on SyncKeys to include Chat
extension ChatSyncKey on SyncKeys {
  static const String chatLastSync = 'chat_last_sync';
}
