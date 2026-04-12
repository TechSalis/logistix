import 'package:shared/shared.dart';

enum ChatUpdateType {
  MESSAGE,
  TYPING,
  STATUS,
}

class ChatUpdate {
  const ChatUpdate({
    required this.type,
    this.message,
    this.typing,
  });

  final ChatUpdateType type;
  final ChatMessage? message;
  final TypingStatus? typing;
}
