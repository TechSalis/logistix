import 'package:flutter/material.dart';
import 'package:logistix/features/auth/application/utils/auth_network_image.dart';
import 'package:logistix/features/auth/domain/entities/user_data.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.radius});

  final UserData user;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CircleAvatar(
      radius: radius,
      backgroundImage:
          user.imageUrl?.isEmpty ?? true
              ? null
              : NetworkImageWithAuth(user.imageUrl!),
      backgroundColor: theme.colorScheme.onSecondary.withAlpha(30),
      child:
          user.name?.isEmpty ?? true
              ? null
              : Text(
                user.name![0].toUpperCase(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimary,
                  fontSize: radius,
                ),
              ),
    );
  }
}
