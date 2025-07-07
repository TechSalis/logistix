import 'package:flutter/material.dart';
import 'package:logistix/features/auth/domain/entities/user_data.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.size});

  final double? size;
  final UserData user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CircleAvatar(
      radius: size,
      backgroundImage:
          user.imageUrl == null ? null : NetworkImage(user.imageUrl!),
      backgroundColor: theme.colorScheme.onSecondary.withAlpha(50),
      child:
          user.name?.isEmpty ?? true
              ? null
              : Text(
                user.name![0].toUpperCase(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                  fontSize: size,
                ),
              ),
    );
  }
}
