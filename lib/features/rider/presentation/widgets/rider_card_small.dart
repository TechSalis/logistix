import 'package:flutter/material.dart';
import 'package:logistix/core/presentation/theme/styling.dart';
import 'package:logistix/core/presentation/widgets/user_avatar.dart';
import 'package:logistix/core/utils/router.dart';
import 'package:logistix/features/auth/domain/entities/user_data.dart';
import 'package:logistix/core/entities/rider_data.dart';

class RiderCardSmall extends StatelessWidget {
  const RiderCardSmall({
    super.key,
    required this.rider,
    this.eta,
    this.decoration,
    this.padding,
  });

  const RiderCardSmall.transparent({super.key, required this.rider, this.eta})
    : decoration = const BoxDecoration(),
      padding = EdgeInsets.zero;

  final Decoration? decoration;
  final EdgeInsets? padding;
  final RiderData rider;
  final String? eta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration:
          decoration ??
          BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: borderRadius_16,
            border: Border.all(color: theme.dividerColor.withAlpha(26)),
            boxShadow: const [
              BoxShadow(
                blurRadius: 2,
                color: Colors.black12,
                offset: Offset(0, 1),
              ),
            ],
          ),
      child: Padding(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(child: UserProfileGroup(user: rider)),
            if (eta != null) ...[
              ETAWidget(eta: eta!),
              const SizedBox(width: 8),
            ],
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                ChatPageRoute(rider).push(context);
              },
              // visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.chat_bubble_outline),
            ),
            IconButton(
              onPressed: () {},
              padding: EdgeInsets.zero,
              // visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.help_outline),
            ),
          ],
        ),
      ),
    );
  }
}

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
                  fontWeight: FontWeight.w600,
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
