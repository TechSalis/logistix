import 'dart:async';

import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/extensions/result_extensions.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:dispatcher/src/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class ChatState {
  const ChatState({
    this.conversations = const [],
    this.activeConversation,
    this.messages = const [],
    this.typingStatus,
    this.isLoading = false,
  });

  final List<Conversation> conversations;
  final Conversation? activeConversation;
  final List<ChatMessage> messages;
  final TypingStatus? typingStatus;
  final bool isLoading;

  ChatState copyWith({
    List<Conversation>? conversations,
    Conversation? activeConversation,
    List<ChatMessage>? messages,
    TypingStatus? typingStatus,
    bool? isLoading,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      activeConversation: activeConversation ?? this.activeConversation,
      messages: messages ?? this.messages,
      typingStatus: typingStatus ?? this.typingStatus,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._repo) : super(const ChatState()) {
    scrollController = ScrollController()..addListener(_onScroll);
    _initSubscription();
  }

  final ChatRepository _repo;
  late final ScrollController scrollController;
  
  String? get myId => _repo.currentUserId;

  StreamSubscription<List<Conversation>>? _convSub;
  StreamSubscription<List<ChatMessage>>? _msgSub;
  StreamSubscription<TypingStatus?>? _typingSub;
  Timer? _typingTimer;

  DateTime? _lastTypingSent;
  int _messagesLimit = 50;
  int _chatLimit = 50;

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (!state.isLoading && state.conversations.length >= _chatLimit) {
        _chatLimit += 50;
        _initSubscription();
      }
    }
  }

  Future<void> _initSubscription() async {
    await _convSub?.cancel();
    _convSub = _repo.watchConversations(limit: _chatLimit).listen((convs) {
      if (isClosed) return;
      emit(state.copyWith(conversations: convs));
    });
  }

  Future<void> refresh() async {
    if (isClosed) return;
    _chatLimit = 50;
    await _initSubscription();
    emit(state.copyWith(isLoading: true, conversations: []));
    
    // Explicit remote delta sync
    final result = await _repo.syncConversations();
    result.when(
      data: (_) => emit(state.copyWith(isLoading: false)),
      error: (_) => emit(state.copyWith(isLoading: false)),
    );
  }

  // ── Mutation Runners ─────────────────────────────────────────────

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

  void selectConversation(String conversationId) {
    if (state.activeConversation?.id == conversationId) return;
    _messagesLimit = 50;
    _subscribeToActiveChat(conversationId);
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

  // ── Subscriptions ────────────────────────────────────────────────

  Future<void> _subscribeToActiveChat(String id) async {
    final currentConv = await _repo.getConversation(id);
    emit(state.copyWith(
      activeConversation: currentConv,
      messages: [],
    ));

    await _msgSub?.cancel();
    _msgSub = _repo
        .watchMessages(id, limit: _messagesLimit)
        .listen((msgs) => emit(state.copyWith(messages: msgs)));

    await _typingSub?.cancel();
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
  Future<void> close() async {
    await _convSub?.cancel();
    await _msgSub?.cancel();
    await _typingSub?.cancel();
    _typingTimer?.cancel();
    scrollController.dispose();
    return super.close();
  }
}
