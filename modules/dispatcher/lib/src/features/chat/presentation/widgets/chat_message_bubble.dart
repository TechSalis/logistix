import 'package:collection/collection.dart';
import 'package:dispatcher/src/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatMessageBubble extends StatefulWidget {
  const ChatMessageBubble({
    required this.message,
    required this.isMe,
    required this.isAi,
    required this.onDelete,
    required this.onRetry,
    this.aiIcon,
    super.key,
  });

  final ChatMessage message;
  final bool isMe;
  final bool isAi;
  final Widget? aiIcon;
  final VoidCallback onDelete;
  final VoidCallback onRetry;

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

class _ChatMessageBubbleState extends State<ChatMessageBubble> {
  final ValueNotifier<bool> _isExpanded = ValueNotifier(false);

  @override
  void dispose() {
    _isExpanded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final isMe = widget.isMe;
    final isAi = widget.isAi;

    final mediaUrl = message.mediaUrl;
    final metadata = message.metadata;
    final hasImage =
        mediaUrl != null && mediaUrl.isNotEmpty && !message.isDeleted;
    final hasLocation =
        metadata != null &&
        metadata.latitude != null &&
        metadata.longitude != null &&
        !message.isDeleted;

    return ValueListenableBuilder<bool>(
      valueListenable: _isExpanded,
      builder: (context, expanded, _) {
        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: BootstrapSpacing.xs),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: hasImage || hasLocation
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(
                    horizontal: BootstrapSpacing.md,
                    vertical: BootstrapSpacing.sm,
                  ),
            decoration: BoxDecoration(
              color: message.isDeleted
                  ? Colors.grey.withValues(alpha: 0.1)
                  : (isMe
                      ? null
                      : (isAi
                          ? LogistixColors.primary.withValues(alpha: 0.1)
                          : Colors.white)),
              gradient: isMe && !message.isDeleted
                  ? const LinearGradient(
                      colors: [LogistixColors.primary, LogistixColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(BootstrapRadii.xl),
                topRight: const Radius.circular(BootstrapRadii.xl),
                bottomLeft: Radius.circular(
                  isMe ? BootstrapRadii.xl : BootstrapRadii.xs,
                ),
                bottomRight: Radius.circular(
                  isMe ? BootstrapRadii.xs : BootstrapRadii.xl,
                ),
              ),
              border: !isMe && !isAi && !message.isDeleted
                  ? Border.all(color: LogistixColors.border.withValues(alpha: 0.5))
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.parentId != null || message.staleParentId != null)
                  _ReplyContext(message: message, isMe: isMe),
                if (hasImage) _ImageContent(url: mediaUrl),
                if (hasLocation) _LocationContent(metadata: metadata, isMe: isMe),
                
                Padding(
                  padding: hasImage || hasLocation
                      ? const EdgeInsets.all(BootstrapSpacing.md)
                      : EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isAi && !message.isDeleted)
                        _AiHeader(name: message.senderName, icon: widget.aiIcon),
                      if (message.body.isNotEmpty && (!message.isDeleted || expanded))
                        Text(
                          message.body,
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: isMe && !message.isDeleted ? Colors.white : Colors.black,
                            fontStyle: message.isDeleted ? FontStyle.italic : null,
                          ),
                        ),
                      if (message.isDeleted && !expanded)
                        _DeletedPlaceholder(onView: () => _isExpanded.value = true),
                      
                      const SizedBox(height: BootstrapSpacing.xxs),
                      _MessageStatusRow(
                        message: message,
                        isMe: isMe,
                        onDelete: widget.onDelete,
                        onRetry: widget.onRetry,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AiHeader extends StatelessWidget {
  const _AiHeader({this.name, this.icon});
  final String? name;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BootstrapSpacing.xxs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) icon!,
          const SizedBox(width: BootstrapSpacing.xxs),
          Text(
            name ?? 'AI Assistant',
            style: context.textTheme.labelSmall?.bold.copyWith(
              color: LogistixColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeletedPlaceholder extends StatelessWidget {
  const _DeletedPlaceholder({required this.onView});
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.delete_outline, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            'This message was deleted',
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onView,
          child: Text(
            'View',
            style: context.textTheme.labelSmall?.bold.copyWith(
              color: LogistixColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageStatusRow extends StatelessWidget {
  const _MessageStatusRow({
    required this.message,
    required this.isMe,
    required this.onDelete,
    required this.onRetry,
  });

  final ChatMessage message;
  final bool isMe;
  final VoidCallback onDelete;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          DateFormat.Hm().format(message.createdAt),
          style: context.textTheme.labelSmall?.copyWith(
            color: isMe && !message.isDeleted
                ? Colors.white.withValues(alpha: 0.7)
                : LogistixColors.textSecondary,
          ),
        ),
        if (isMe && !message.isDeleted) ...[
          const SizedBox(width: 4),
          _StatusIcon(
            status: message.status,
            onRetry: onRetry,
          ),
          if (message.status != MessageStatus.PENDING) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(Icons.delete_outline, size: 14, color: Colors.white70),
            ),
          ],
        ],
      ],
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status, required this.onRetry});
  final MessageStatus status;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageStatus.PENDING:
        return const Icon(Icons.access_time, size: 12, color: Colors.white70);
      case MessageStatus.FAILED:
        return GestureDetector(
          onTap: onRetry,
          child: const Icon(Icons.refresh_rounded, size: 14, color: Colors.white),
        );
      case MessageStatus.READ:
        return const Icon(Icons.done_all, size: 14, color: Colors.lightBlueAccent);
      case MessageStatus.DELIVERED:
        return const Icon(Icons.done_all, size: 14, color: Colors.white70);
      case MessageStatus.SENT:
        return const Icon(Icons.check, size: 14, color: Colors.white70);
    }
  }
}

class _ReplyContext extends StatelessWidget {
  const _ReplyContext({required this.message, required this.isMe});
  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final chatCubit = context.read<ChatCubit>();
    final parent = chatCubit.state.messages.firstWhereOrNull((m) => m.id == message.parentId);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(BootstrapRadii.md),
        border: Border(
          left: BorderSide(
            color: isMe ? Colors.white70 : LogistixColors.primary,
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.reply_rounded, size: 12, color: isMe ? Colors.white70 : LogistixColors.primary),
              const SizedBox(width: 4),
              Text(
                parent != null ? (parent.senderType == SenderType.CUSTOMER ? 'Customer' : 'Support') : 'Older Message',
                style: context.textTheme.labelSmall?.bold.copyWith(
                  color: isMe ? Colors.white : LogistixColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            parent?.body ?? (message.staleParentId != null ? 'Original message archived' : 'Original message not found'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              color: isMe ? Colors.white70 : LogistixColors.textSecondary,
              fontStyle: parent == null ? FontStyle.italic : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageContent extends StatelessWidget {
  const _ImageContent({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(BootstrapRadii.xl),
        topRight: Radius.circular(BootstrapRadii.xl),
      ),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        loadingBuilder: (context, child, progress) => progress == null ? child : _ImageLoader(),
        errorBuilder: (context, _, __) => _ImageError(),
      ),
    );
  }
}

class _ImageLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 200, color: LogistixColors.surfaceDim, child: const Center(child: BootstrapInlineLoader()));
  }
}

class _ImageError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: LogistixColors.surfaceDim,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_not_supported_outlined, color: LogistixColors.textTertiary),
          const SizedBox(height: 8),
          Text('Image unavailable', style: context.textTheme.labelSmall?.copyWith(color: LogistixColors.textTertiary)),
        ],
      ),
    );
  }
}

class _LocationContent extends StatelessWidget {
  const _LocationContent({required this.metadata, required this.isMe});
  final MessageMetadata metadata;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${metadata.latitude},${metadata.longitude}');
        if (await canLaunchUrl(uri)) await launchUrl(uri);
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isMe ? Colors.white12 : LogistixColors.surfaceDim,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(BootstrapRadii.xl),
            topRight: Radius.circular(BootstrapRadii.xl),
          ),
        ),
        padding: const EdgeInsets.all(BootstrapSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.location_on_rounded, color: LogistixColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Shared Location', style: context.textTheme.labelLarge?.bold),
                  Text('Tap to open in Maps', style: context.textTheme.labelSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
