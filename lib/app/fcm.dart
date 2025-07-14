import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


final _firebaseMessaging = FirebaseMessaging.instance;

Future<void> setupFCM() async {
  final settings = await _firebaseMessaging.requestPermission();
  
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    // Get token
    final token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      print("Foreground message: ${message.notification?.title}");
    });
  }
}

// Background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Background message: ${message.messageId}");
}
