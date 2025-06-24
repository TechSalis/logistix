import 'package:flutter/material.dart';

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({
    super.key,
    required this.backgroundColor,
    required this.icon,
    this.foregroundImage,
  });

  final Color backgroundColor;
  final ImageProvider<Object>? foregroundImage;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: backgroundColor,
      foregroundImage: foregroundImage,
      child: FittedBox(child: icon),
    );
  }
}
