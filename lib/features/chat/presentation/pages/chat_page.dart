
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flyer_chat_text_message/flyer_chat_text_message.dart';
import 'package:logistix/core/constants/global_instances.dart';
import 'package:logistix/core/presentation/widgets/user_avatar.dart';
import 'package:logistix/features/customer_auth/application/logic/auth_rp.dart';
import 'package:logistix/core/entities/user_base.dart';
import 'package:logistix/features/rider/domain/entities/rider.dart';
import 'package:flyer_chat_system_message/flyer_chat_system_message.dart';

class ChatParameters<T extends UserBase> {
  ChatParameters({required this.user});
  final T user;
}

class ChatPage<T extends UserBase> extends ConsumerStatefulWidget {
  const ChatPage({super.key, required this.data});
  final ChatParameters<T> data;

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends ConsumerState<ChatPage> {
  final _chatController = InMemoryChatController();

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = (ref.read(authProvider) as AuthLoggedIn).user;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            UserAvatar(user: widget.data.user, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data.user.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.data.user is Rider)
                    Text(
                      (widget.data.user as Rider).company ?? 'Independent',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.help_outline)),
        ],
      ),
      body: Chat(
        chatController: _chatController,
        currentUserId: user.id,
        theme: ChatTheme.fromThemeData(Theme.of(context)).copyWith(
          colors: ChatColors.fromThemeData(Theme.of(context)).copyWith(
            primary: Theme.of(context).colorScheme.secondary,
            onPrimary: Colors.white,
            surface: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
        builders: Builders(
          composerBuilder: (_) {
            return Composer(
              sendIconColor: Theme.of(context).colorScheme.onPrimary,
              emptyFieldSendIconColor: Theme.of(context).dividerColor,
              attachmentIconColor: Theme.of(context).colorScheme.onPrimary,
            );
          },
          // chatMessageBuilder: (
          //   _,
          //   message,
          //   index,
          //   animation,
          //   child, {
          //   bool? isRemoved,
          //   required bool isSentByMe,
          //   MessageGroupStatus? groupStatus,
          // }) {
          //   return ChatMessage(
          //     message: message,
          //     index: index,
          //     animation: animation,
          //     isRemoved: isRemoved,
          //     groupStatus: groupStatus,
          //     child: child,
          //   );
          // },
          systemMessageBuilder: (
            _,
            message,
            index, {
            required isSentByMe,
            groupStatus,
          }) {
            return FlyerChatSystemMessage(message: message, index: index);
          },
          textMessageBuilder: (
            _,
            message,
            index, {
            groupStatus,
            required isSentByMe,
          }) {
            bool isFirst = groupStatus?.isFirst ?? true;
            return FlyerChatTextMessage(
              index: index,
              message: message,
              timeAndStatusPosition: TimeAndStatusPosition.inline,
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              timeAndStatusPositionInlineInsets: const EdgeInsets.only(left: 6),
              timeStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    isSentByMe
                        ? Theme.of(context).colorScheme.surface
                        : Theme.of(context).colorScheme.onSurface,
                height: .6,
              ),
              borderRadius: BorderRadius.only(
                topLeft:
                    isFirst && !isSentByMe
                        ? Radius.zero
                        : const Radius.circular(10),
                topRight:
                    isFirst && isSentByMe
                        ? Radius.zero
                        : const Radius.circular(10),
                bottomLeft: const Radius.circular(10),
                bottomRight: const Radius.circular(10),
              ),
            );
          },
        ),
        onAttachmentTap: () {
          //
        },
        onMessageLongPress: (
          message, {
          LongPressStartDetails? details,
          int? index,
        }) {
          //
        },
        onMessageSend: (text) async {
          final now = DateTime.now().toUtc();
          if (_chatController.messages.isEmpty) {
            await _chatController.insertMessage(
              SystemMessage(
                id: now.toIso8601String(),
                authorId: 'system',
                text: 'Today',
                createdAt: now.subtract(const Duration(seconds: 1)),
              ),
            );
          }

          _chatController.insertMessage(
            TextMessage(
              id: uuid.v4(),
              authorId: user.id,
              createdAt: now,
              text: text,
            ),
          );
        },
        resolveUser: (UserID id) async {
          if (user.id == id) return user.toUser();
          if (widget.data.user.id == id) return widget.data.user.toUser();
          return null;
        },
      ),
    );
  }
}

extension ToChatUserModel on UserBase {
  User toUser() {
    return User(id: id, name: name, imageSource: imageSource);
  }
}
