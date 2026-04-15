import 'dart:async';
import 'package:adapters/logger/logger.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

abstract class PushNotificationService {
  Future<void> init();
  Future<String?> getFirebaseToken();
  Future<void> requestPermission();
  Future<void> deleteToken();
  Stream<String> get onTokenRefresh;
}

class PushNotificationServiceImpl implements PushNotificationService {
  PushNotificationServiceImpl();

  static final _tokenController = StreamController<String>.broadcast();

  @override
  Stream<String> get onTokenRefresh => _tokenController.stream;

  @override
  Future<void> init() async {
    await AwesomeNotifications().initialize(
      null, // default icon
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: LogistixColors.primary,
          ledColor: LogistixColors.white,
          importance: NotificationImportance.High,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'basic_channel_group',
          channelGroupName: 'Basic group',
        ),
      ],
      debug: EnvConfig.instance.isDevelopment,
    );

    await AwesomeNotificationsFcm().initialize(
      onFcmTokenHandle: _onFcmTokenHandle,
      onFcmSilentDataHandle: _onFcmSilentDataHandle,
      debug: EnvConfig.instance.isDevelopment,
    );
  }

  @override
  Future<String?> getFirebaseToken() {
    return AwesomeNotificationsFcm().requestFirebaseAppToken();
  }

  @override
  Future<void> requestPermission() async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      await AwesomeNotificationsFcm().deleteToken();
      appLogger.debug('FCM Token deleted successfully');
    } catch (e) {
      appLogger.error('Error deleting FCM token: $e');
    }
  }

  static Future<void> _onFcmTokenHandle(String token) async {
    _tokenController.add(token);
  }

  static Future<void> _onFcmSilentDataHandle(FcmSilentData data) async {
    appLogger.debug('Silent Data: $data');
  }
}
