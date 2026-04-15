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
    _chatCubit.selectConversation(widget.conversationId);
    _scrollController.addListener(_onScroll);
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
          backgroundColor: LogistixColors.background,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.senderType == SenderType.DISPATCHER;
        final isAi =
            message.senderType == SenderType.SYSTEM ||
            message.senderType == SenderType.AGENT;

        return Padding(
          padding: EdgeInsets.only(
            bottom: index == 0 ? 8 : 4,
            top: index == messages.length - 1 ? 8 : 4,
          ),
          child: ChatMessageBubble(
            message: message,
            isMe: isMe,
            isAi: isAi,
            onDelete: () => _chatCubit.deleteMessage(message.id),
            onRetry: () => _chatCubit.retryMessage(message),
          ),
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
            onPressed: isLoading
                ? null
                : () => chatCubit.toggleAutoReplyRunner(false),
            icon: isLoading
                ? const _LoadingIcon()
                : const Icon(Icons.front_hand_outlined, size: 18),
            label: const Text('Take Control'),
            style: TextButton.styleFrom(foregroundColor: LogistixColors.error),
          );
        } else {
          return IconButton(
            onPressed: isLoading
                ? null
                : () => chatCubit.toggleAutoReplyRunner(true),
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: LogistixColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: LogistixColors.border),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: LogistixColors.textSecondary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Start the conversation',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Send a message to begin chatting with this customer',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: LogistixColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
