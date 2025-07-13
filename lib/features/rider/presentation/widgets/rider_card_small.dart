import 'package:flutter/material.dart';
import 'package:logistix/app/presentation/widgets/user_avatar.dart';
import 'package:logistix/features/auth/domain/entities/user_data.dart';
import 'package:logistix/app/domain/entities/rider_data.dart';

class UserProfileGroup extends StatelessWidget {
  const UserProfileGroup({super.key, required this.user});
  final UserData user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        UserAvatar(user: user, size: 18),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name ?? '',
                maxLines: 1,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (user is RiderData)
                Text(
                  (user as RiderData).company?.name ?? 'Independent',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class ETAWidget extends StatelessWidget {
  const ETAWidget({super.key, required this.eta});
  final String eta;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).iconTheme.color?.withAlpha(160);
    return Row(
      children: [
        Icon(Icons.timer_outlined, size: 16, color: color),
        const SizedBox(width: 4),
        Text(eta, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
