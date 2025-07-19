import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/chat/presentation/models/chat_message.dart';
import 'package:logistix/features/chat/presentation/widgets/message_widget.dart';

final messageListProvider =
    StateNotifierProvider<MessageListController, List<Message>>(
      (ref) => MessageListController(),
    );

class MessageListController extends StateNotifier<List<Message>> {
  MessageListController() : super([]);

  final _animatedListKey = GlobalKey<AnimatedListState>();
  GlobalKey<AnimatedListState> get listKey => _animatedListKey;

  void addMessage(Message msg) {
    state = [msg, ...state];
    _animatedListKey.currentState?.insertItem(0);
  }

  void removeMessage(int index) {
    final removed = state[index];
    state = [...state]..removeAt(index);
    _animatedListKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: MessageBubble(message: removed),
      ),
    );
  }
}
