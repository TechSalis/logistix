import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/app/application/navigation_bar_rp.dart';
import 'package:logistix/features/notifications/domain/entities/notification_data.dart';
import 'package:logistix/features/notifications/presentation/notifications/notification_widget.dart';
import 'package:logistix/features/quick_actions/domain/quick_actions_types.dart';
import 'package:logistix/features/quick_actions/presentation/widgets/quick_action_widget.dart';
import 'package:logistix/features/rider/domain/entities/rider.dart';

class RiderFoundNotification extends AppNotificationData {
  const RiderFoundNotification({required this.rider, this.key});

  final Rider rider;

  @override
  final NotificationKey? key;

  @override
  List<Object?> get props => [key, rider];
}

class RiderFoundNotificationWidget extends ConsumerWidget {
  const RiderFoundNotificationWidget({super.key, required this.data});
  final RiderFoundNotification data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final title =
        '${data.rider.name}  •  ${data.rider.company ?? "Independent"}';
    openOrdersTab() async {
      ref.read(navBarIndexProvider.notifier).state = 1;
      await Future.delayed(Durations.medium4);
      AppNotifications.dismiss(data: data);
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Material(
          elevation: 8,
          shadowColor: Colors.black38,
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: openOrdersTab,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Icon
                  const ActionIcon(action: ActionType.delivery, size: 42),
                  const SizedBox(width: 16),

                  // Textual content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "📍 Rider is on their way!",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Action button
                  Consumer(
                    builder: (context, ref, _) {
                      return IconButton(
                        visualDensity: VisualDensity.compact,
                        style: IconButton.styleFrom(
                          side: BorderSide.none,
                          elevation: 0,
                        ),
                        onPressed: openOrdersTab,
                        icon: const Icon(Icons.info_outline),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
