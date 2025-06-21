import 'package:flutter/material.dart';
import 'package:logistix/features/quick_actions/domain/quick_actions_types.dart';
import 'package:logistix/features/quick_actions/presentation/widgets/quick_action_widget.dart';
import 'package:logistix/features/rider/domain/entities/rider.dart';

class QARiderNotificationWidget extends StatelessWidget {
  const QARiderNotificationWidget({
    super.key,
    required this.action,
    required this.rider,
    required this.onMore,
    required this.onCancel,
  });

  final Rider rider;
  final QuickAction action;
  final VoidCallback onMore;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    TextField;
    return SafeArea(
      child: Card(
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: ListTile(
          titleTextStyle: Theme.of(context).textTheme.titleMedium,
          contentPadding: EdgeInsets.only(left: 12, right: 4),
          leading: QuickActionIcon(action: action),
          title: Text(
            rider.name +
                (rider.company == null ? '' : '  •  ${rider.company!}'),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          subtitle: Text("📍 Rider is on their way!"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onMore,
                icon: Badge.count(count: 1, child: Icon(Icons.info_outline)),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onCancel,
                icon: Icon(Icons.close),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
