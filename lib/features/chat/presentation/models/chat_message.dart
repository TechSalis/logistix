
enum MessageStatus { sent, delivered, seen }

class Message {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isMe;
  final MessageStatus status;

  Message({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isMe,
    this.status = MessageStatus.sent,
  });
}
