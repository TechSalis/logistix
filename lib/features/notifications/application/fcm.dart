part of 'notification_service.dart';

final _firebaseMessaging = FirebaseMessaging.instance;

Future<void> _setupFCM() async {
  // Get token
  final token = await _firebaseMessaging.getToken();
  print('FCM Token: $token');

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((message) {});
}

// Background handler
@pragma("vm:entry-point")
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Background message: ${message.messageId}");
}
