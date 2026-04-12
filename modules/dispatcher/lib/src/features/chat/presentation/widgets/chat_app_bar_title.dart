import 'package:dispatcher/src/core/extensions/chat_platform_extension.dart';
import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class ChatAppBarTitle extends StatelessWidget {
  const ChatAppBarTitle({
    required this.conversation,
    required this.typingStatus,
    required this.myId,
    super.key,
  });

  final Conversation conversation;
  final TypingStatus? typingStatus;
  final String? myId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ConversationAvatar(conversation: conversation),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                conversation.customerName ?? conversation.platformId,
                style: Theme.of(context).textTheme.titleLarge?.bold,
              ),
              _StatusSubtitle(
                autoReplyEnabled: conversation.autoReplyEnabled,
                typingStatus: typingStatus,
                myId: myId,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConversationAvatar extends StatelessWidget {
  const _ConversationAvatar({required this.conversation});
  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Hero(
          tag: 'avatar_${conversation.id}',
          child: BootstrapAvatar(
            name: conversation.customerName ?? conversation.platformId,
            size: 36,
          ),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: conversation.platform.icon(size: 12),
          ),
        ),
      ],
    );
  }
}

class _StatusSubtitle extends StatelessWidget {
  const _StatusSubtitle({
    required this.autoReplyEnabled,
    required this.typingStatus,
    this.myId,
  });

  final bool autoReplyEnabled;
  final TypingStatus? typingStatus;
  final String? myId;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: () {
        if (typingStatus == null || !typingStatus!.isTyping || typingStatus!.senderId == myId) {
          return Text(
            autoReplyEnabled ? 'Auto-Reply active' : 'Manual mode',
            key: ValueKey(autoReplyEnabled),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: autoReplyEnabled ? LogistixColors.primary : LogistixColors.textSecondary,
              fontWeight: autoReplyEnabled ? FontWeight.bold : FontWeight.normal,
            ),
          );
        }

        var typingText = 'Customer is typing...';
        if (typingStatus!.senderType == SenderType.SYSTEM && typingStatus!.senderId == null) {
          typingText = 'AI Agent is typing...';
        }

        return Text(
          typingText,
          key: const ValueKey('typing'),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: LogistixColors.primary,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        );
      }(),
    );
  }
}
