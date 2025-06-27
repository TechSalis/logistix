import 'package:flutter/material.dart';
import 'package:logistix/core/presentation/widgets/user_avatar.dart';
import 'package:logistix/features/chat/presentation/pages/chat_page.dart';
import 'package:logistix/features/rider/domain/entities/rider.dart';

class RiderCardSmall extends StatelessWidget {
  const RiderCardSmall({
    super.key,
    required this.rider,
    this.eta,
    this.borderRadius,
  });

  final Rider rider;
  final String? eta;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius:
            borderRadius ?? const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: theme.dividerColor.withAlpha(26)),
        boxShadow: const [
          BoxShadow(blurRadius: 2, color: Colors.black12, offset: Offset(0, 1)),
        ],
      ),
      child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            UserAvatar(user: rider, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rider.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    rider.company ?? 'Independent',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (eta != null) ...[
              ETAWidget(eta: eta!),
              const SizedBox(width: 8),
            ],
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatPage(data: ChatParameters(user: rider)),
                  ),
                );
              },
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.chat_bubble_outline, size: 20),
            ),
            IconButton(
              onPressed: () {},
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.help_outline, size: 20),
            ),
          ],
        ),
      ),
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
