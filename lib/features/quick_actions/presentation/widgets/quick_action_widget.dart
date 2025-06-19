import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logistix/features/quick_actions/presentation/quick_actions_enum.dart';

class QuickActionIcon extends StatelessWidget {
  const QuickActionIcon({super.key, required this.action, required this.size});

  final double size;
  final QuickAction action;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size * .5,
      backgroundColor: action.color.withAlpha(40),
      child: FittedBox(
        child: Icon(action.icon, size: size * .5, color: action.color),
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
              SizedBox(height: 4.h),
              Text(
                action.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
