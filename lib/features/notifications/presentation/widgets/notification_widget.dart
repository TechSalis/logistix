import 'package:flutter/material.dart';
import 'package:logistix/features/notifications/presentation/widgets/notification_icon_button.dart';

class CustomAppBarNotificationButton extends StatelessWidget {
  const CustomAppBarNotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 16, 0),
          child: NotificationIconButton(),
        ),
      ),
    );
  }
}

class MessageNotification extends StatelessWidget {
  const MessageNotification({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Card(
        margin: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: ListTile(
          contentPadding: EdgeInsets.only(left: 16, right: 8),
          leading: Icon(Icons.person),
          title: Text('Lily MacDonald'),
          subtitle: Text('Do you want to see a movie?'),
        ),
      ),
    );
  }
}
