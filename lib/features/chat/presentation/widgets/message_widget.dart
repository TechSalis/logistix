import 'package:flutter/material.dart';
import 'package:logistix/features/chat/presentation/models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bubbleColor = message.isMe
        ? (isDark ? Colors.teal[700] : Colors.green[300])
        : (isDark ? Colors.grey[800] : Colors.grey[300]);

    final alignment = message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: message.isMe ? const Radius.circular(16) : const Radius.circular(0),
      bottomRight: message.isMe ? const Radius.circular(0) : const Radius.circular(16),
    );

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: borderRadius,
          ),
          child: Column(
            crossAxisAlignment: alignment,
            children: [
              Text(
                message.text,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  Text(
                    timeFormat(message.timestamp),
                    style: theme.textTheme.labelSmall?.copyWith(color: Colors.white70, fontSize: 10),
                  ),
                  if (message.isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      statusIcon(message.status),
                      size: 14,
                      color: message.status == MessageStatus.seen
                          ? Colors.lightBlueAccent
                          : Colors.white70,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String timeFormat(DateTime dt) => "${dt.hour}:${dt.minute}";

  IconData statusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.seen:
        return Icons.done_all;
    }
  }
}
