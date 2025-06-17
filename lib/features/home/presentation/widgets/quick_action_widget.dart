import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logistix/features/quick_actions/presentation/quick_actions_enum.dart';

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
              Expanded(
                child: CircleAvatar(
                  backgroundColor: action.color,
                  radius: 24.r,
                  child: Hero(tag: action.icon, child: Icon(action.icon)),
                ),
              ),
              SizedBox(height: 8.h),
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
