import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/auth/domain/entities/user_data.dart';
import 'package:logistix/features/chat/application/logic/chat_rp.dart';
import 'package:logistix/features/chat/presentation/widgets/message_widget.dart';

class ChatPage<T extends UserData> extends ConsumerWidget {
  const ChatPage({super.key, required this.user});
  final T user;
  // final List<Message> messages;
  // final void Function(String) onSend;

  // const ChatPage({super.key, required this.messages, required this.onSend});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final messages = ref.watch(messageListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                return AnimatedList(
                  key: ref.read(messageListProvider.notifier).listKey,
                  initialItemCount: messages.length,
                  itemBuilder: (context, index, animation) {
                    final msg = messages[index];
                    return SlideFadeTransition(
                      animation: animation,
                      child: MessageBubble(message: msg),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      // onSend(controller.text.trim());
                      controller.clear();
                      // ref
                      //     .read(messageListProvider.notifier)
                      //     .addMessage(
                      //       Message(
                      //         text: "Hey! 👋",
                      //         isSentByMe: true,
                      //         timestamp: DateTime.now(),
                      //       ),
                      //     );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedChatListView extends ConsumerWidget {
  const AnimatedChatListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messageListProvider);
    final controller = ref.read(messageListProvider.notifier);
    final listKey = controller.listKey;

    return AnimatedList(
      key: listKey,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      initialItemCount: messages.length,
      itemBuilder: (context, index, animation) {
        final msg = messages[index];
        return SlideFadeTransition(
          animation: animation,
          child: MessageBubble(message: msg),
        );
      },
    );
  }
}

class SlideFadeTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  const SlideFadeTransition({
    super.key,
    required this.child,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

    return SlideTransition(
      position: offsetAnimation,
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}
