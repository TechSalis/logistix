import 'dart:async';

import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:collection/collection.dart';
import 'package:dispatcher/src/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:dispatcher/src/features/chat/presentation/widgets/chat_app_bar_title.dart';
import 'package:dispatcher/src/features/chat/presentation/widgets/chat_input_bar.dart';
import 'package:dispatcher/src/features/chat/presentation/widgets/chat_message_bubble.dart';
import 'package:dispatcher/src/features/chat/presentation/widgets/send_media_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

/// Refactored, modular Chat Detail Page.
/// 
/// Business logic is fully delegated to [ChatCubit].
/// UI is composed of smaller, focused widgets.
class ChatDetailPage extends StatefulWidget {
  const ChatDetailPage({required this.conversationId, super.key});

  final String conversationId;

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final ScrollController _scrollController = ScrollController();
  late final ChatCubit _chatCubit;

  @override
  void initState() {
    super.initState();
    _chatCubit = context.read<ChatCubit>();
    _scrollController.addListener(_onScroll);

    _ensureConversationSelected();
  }

  void _ensureConversationSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatCubit.state.activeConversation?.id != widget.conversationId) {
        final conversation = _chatCubit.state.conversations.firstWhereOrNull(
          (c) => c.id == widget.conversationId,
        );
        if (conversation != null) _chatCubit.selectConversation(conversation);
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _chatCubit.loadMoreMessages();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final conversation = state.activeConversation;
        if (conversation == null) {
          return const Scaffold(body: Center(child: BootstrapInlineLoader()));
        }

        return Scaffold(
          appBar: _buildAppBar(context, conversation, state.typingStatus),
          body: BlocListener<ChatCubit, ChatState>(
            listenWhen: (prev, curr) =>
                curr.messages.length > prev.messages.length &&
                curr.messages.firstOrNull?.senderType == SenderType.DISPATCHER,
            listener: (context, state) => _scrollToBottom(),
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () {
                      return _chatCubit.refreshMessages(widget.conversationId);
                    },
                    child: _buildMessageList(state.messages),
                  ),
                ),
                ChatInputBar(
                  onSend: (text) async {
                    await _chatCubit.sendMessageRunner(text);
                    _scrollToBottom();
                  },
                  onMedia: _handleMediaUpload,
                  onTyping: _chatCubit.onTyping,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    Conversation conversation,
    TypingStatus? typingStatus,
  ) {
    return AppBar(
      titleSpacing: 0,
      title: ChatAppBarTitle(
        conversation: conversation,
        typingStatus: typingStatus,
        myId: _chatCubit.myId,
      ),
      actions: [
        _AiToggle(conversation: conversation),
        IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
      ],
    );
  }

  Widget _buildMessageList(List<ChatMessage> messages) {
    if (messages.isEmpty) {
      return const _EmptyResultsPlaceholder();
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.all(BootstrapSpacing.lg),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return ChatMessageBubble(
          message: message,
          isMe: message.senderType == SenderType.DISPATCHER,
          isAi: (message.senderType == SenderType.SYSTEM || message.senderType == SenderType.AGENT) && 
                message.senderId == null,
          onDelete: () => _chatCubit.deleteMessage(message.id),
          onRetry: () => _chatCubit.retryMessage(message),
        );
      },
    );
  }

  Future<void> _handleMediaUpload() async {
    final result = await SendMediaDialog.show(context);
    if (result != null) {
      await _chatCubit.sendMediaMessageRunner((
        url: result.url,
        caption: result.caption,
      ));
      _scrollToBottom();
    }
  }
}

class _AiToggle extends StatelessWidget {
  const _AiToggle({required this.conversation});
  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    final chatCubit = context.read<ChatCubit>();
    return AsyncRunnerBuilder(
      runner: chatCubit.toggleAutoReplyRunner,
      builder: (context, runnerState, _) {
        final isLoading = runnerState.status.isRunning;
        if (conversation.autoReplyEnabled) {
          return TextButton.icon(
            onPressed: isLoading ? null : () => chatCubit.toggleAutoReplyRunner(false),
            icon: isLoading
                ? const _LoadingIcon()
                : const Icon(Icons.front_hand_outlined, size: 18),
            label: const Text('Take Control'),
            style: TextButton.styleFrom(foregroundColor: LogistixColors.error),
          );
        } else {
          return IconButton(
            onPressed: isLoading ? null : () => chatCubit.toggleAutoReplyRunner(true),
            icon: isLoading
                ? const _LoadingIcon()
                : const Icon(Icons.auto_awesome_outlined),
            tooltip: 'Enable Auto-Reply',
            color: LogistixColors.primary,
          );
        }
      },
    );
  }
}

class _LoadingIcon extends StatelessWidget {
  const _LoadingIcon();
  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
}

class _EmptyResultsPlaceholder extends StatelessWidget {
  const _EmptyResultsPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline_rounded,
            color: LogistixColors.textTertiary,
            size: 48,
          ),
          const SizedBox(height: BootstrapSpacing.md),
          Text(
            'No messages yet',
            style: context.textTheme.bodyMedium?.copyWith(
              color: LogistixColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
