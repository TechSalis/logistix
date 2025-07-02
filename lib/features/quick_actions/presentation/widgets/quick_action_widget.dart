import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logistix/features/notifications/presentation/widgets/notification_profile_icon.dart';
import 'package:logistix/features/quick_actions/presentation/quick_actions_types.dart';

class QuickActionIcon extends StatelessWidget {
  const QuickActionIcon({super.key, required this.action, this.size});
  final QuickActionType action;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: AvatarIcon(
        backgroundColor: action.color.withAlpha(20),
        icon: Icon(
          action.icon,
          color: action.color,
          size: size != null ? (size! * .6) : null,
        ),
      ),
    );
  }
}

class QuickActionWidget extends StatelessWidget {
  const QuickActionWidget({
    super.key,
    required this.action,
    required this.onTap,
  });

  final QuickActionType action;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.h),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: action.color.withAlpha(10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: action.color.withAlpha(90)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
            child: Column(
              children: [
                Expanded(child: QuickActionIcon(action: action)),
                SizedBox(height: 6.h),
                Text(
                  action.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
