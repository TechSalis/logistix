import 'dart:async';

import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/extensions/result_extensions.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:collection/collection.dart';
import 'package:dispatcher/src/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class ChatState {
  const ChatState({
    this.conversations = const [],
    this.activeConversation,
    this.messages = const [],
    this.typingStatus,
  });

  final List<Conversation> conversations;
  final Conversation? activeConversation;
  final List<ChatMessage> messages;
  final TypingStatus? typingStatus;

  ChatState copyWith({
    List<Conversation>? conversations,
    Conversation? activeConversation,
    List<ChatMessage>? messages,
    TypingStatus? typingStatus,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      activeConversation: activeConversation ?? this.activeConversation,
      messages: messages ?? this.messages,
      typingStatus: typingStatus ?? this.typingStatus,
    );
  }
}

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._repo) : super(const ChatState()) {
    _subscribeToConversations();
  }

  final ChatRepository _repo;
  String? get myId => _repo.currentUserId;

  StreamSubscription<List<Conversation>>? _convSub;
  StreamSubscription<List<ChatMessage>>? _msgSub;
  StreamSubscription<TypingStatus?>? _typingSub;
  Timer? _typingTimer;

  DateTime? _lastTypingSent;
  int _messagesLimit = 50;

  // ── Mutation Runners ─────────────────────────────────────────────

  late final fetchConversationsRunner = AsyncRunner<AppError, List<Conversation>>(() async {
    final result = await _repo.fetchConversations();
    return result.throwOrReturn();
  });

  late final sendMessageRunner = AsyncRunner.withArg<String, AppError, ChatMessage>((body) async {
    if (state.activeConversation == null) throw const AppError(message: 'No active conversation');
    final result = await _repo.sendManualMessage(
      conversationId: state.activeConversation!.id,
      body: body,
    );
    return result.throwOrReturn();
  });

  late final sendMediaMessageRunner = AsyncRunner.withArg<({String url, String? caption}), AppError, ChatMessage>((media) async {
    if (state.activeConversation == null) throw const AppError(message: 'No active conversation');
    final result = await _repo.sendMediaMessage(
      conversationId: state.activeConversation!.id,
      mediaUrl: media.url,
      caption: media.caption,
    );
    return result.throwOrReturn();
  });

  late final toggleAutoReplyRunner = AsyncRunner.withArg<bool, AppError, bool>((enabled) async {
    if (state.activeConversation == null) throw const AppError(message: 'No active conversation');
    final result = await _repo.toggleAutoReply(
      conversationId: state.activeConversation!.id,
      enabled: enabled,
    );
    return result.throwOrReturn();
  });

  late final sendTypingIndicatorRunner = AsyncRunner<AppError, bool>(() async {
    if (state.activeConversation == null) return false;
    
    final now = DateTime.now();
    if (_lastTypingSent != null && now.difference(_lastTypingSent!).inSeconds < 2) {
      return true;
    }
    _lastTypingSent = now;
    
    final result = await _repo.sendTypingIndicator(state.activeConversation!.id);
    return result.throwOrReturn();
  });

  // ── Actions ──────────────────────────────────────────────────────

  void selectConversation(Conversation conversation) {
    if (state.activeConversation?.id == conversation.id) return;
    _messagesLimit = 50;
    _subscribeToActiveChat(conversation.id);
  }

  void onTyping() => sendTypingIndicatorRunner();

  Future<void> deleteMessage(String messageId) async {
    await _repo.deleteMessage(messageId);
  }
  
  Future<void> refreshMessages(String conversationId) async {
    await _repo.syncMessages(conversationId);
  }
  
  void retryMessage(ChatMessage message) {
    if (message.mediaUrl != null) {
      sendMediaMessageRunner((url: message.mediaUrl!, caption: message.body));
    } else {
      sendMessageRunner(message.body);
    }
    // Remove the failed one to prevent duplicates in UI
    deleteMessage(message.id);
  }

  void loadMoreMessages() {
    if (state.activeConversation == null) return;
    _messagesLimit += 50;
    _subscribeToActiveChat(state.activeConversation!.id);
  }

  // ── Subscriptions ────────────────────────────────────────────────

  void _subscribeToConversations() {
    _convSub?.cancel();
    _convSub = _repo.watchConversations().listen((convs) => emit(state.copyWith(conversations: convs)));
  }

  void _subscribeToActiveChat(String id) {
    final currentConv = state.conversations.firstWhereOrNull((c) => c.id == id);
    emit(state.copyWith(
      activeConversation: currentConv,
      messages: [],
    ));

    _msgSub?.cancel();
    _msgSub = _repo
        .watchMessages(id, limit: _messagesLimit)
        .listen((msgs) => emit(state.copyWith(messages: msgs)));

    _typingSub?.cancel();
    _typingSub = _repo.watchTyping(id).listen((typing) {
      if (typing?.conversationId == state.activeConversation?.id) {
        emit(state.copyWith(typingStatus: typing));
        _typingTimer?.cancel();
        if (typing != null && typing.isTyping) {
          _typingTimer = Timer(const Duration(seconds: 10), () => emit(state.copyWith()));
        }
      }
    });
  }

  @override
  Future<void> close() {
    _convSub?.cancel();
    _msgSub?.cancel();
    _typingSub?.cancel();
    _typingTimer?.cancel();
    return super.close();
  }
}
