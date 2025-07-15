import 'package:flutter/material.dart';
import 'package:logistix/features/home/presentation/widgets/user_avatar.dart';
import 'package:logistix/features/home/domain/entities/rider_data.dart';

class RiderProfileGroup extends StatelessWidget {
  const RiderProfileGroup({super.key, required this.user});
  final RiderData user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        UserAvatar(user: user, radius: 16),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                maxLines: 1,
                style: theme.textTheme.labelLarge,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                user.company?.name ?? 'Independent',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w300,
                  height: 1.2,
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
