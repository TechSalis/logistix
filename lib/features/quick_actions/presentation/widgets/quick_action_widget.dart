import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logistix/features/quick_actions/domain/quick_actions_types.dart';

class QuickActionIcon extends StatelessWidget {
  const QuickActionIcon({super.key, required this.action, this.size});

  final double? size;
  final QuickAction action;

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    final _size = size != null ? size! * .5 : null;
    return CircleAvatar(
      radius: _size,
      backgroundColor: action.color.withAlpha(40),
      child: FittedBox(
        child: Icon(action.icon, size: _size, color: action.color),
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

  final QuickAction action;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.symmetric(horizontal: 4.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
          child: Column(
            children: [
              Expanded(child: QuickActionIcon(action: action, size: 50.r)),
              SizedBox(height: 6.h),
              Text(
                action.name,
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
    );
  }
}
