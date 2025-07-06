import 'package:flutter/material.dart';
import 'package:logistix/core/entities/user_base.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.size});

  final double? size;
  final UserBase user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CircleAvatar(
      radius: size,
      backgroundImage:
          user.imageSource == null ? null : NetworkImage(user.imageSource!),
      backgroundColor: theme.colorScheme.onSecondary.withAlpha(50),
      child: Text(
        user.name[0].toUpperCase(),
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimary,
          fontSize: size,
        ),
      ),
    );
  }
}
