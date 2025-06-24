import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logistix/features/quick_actions/domain/quick_actions_types.dart';

class QuickActionCard extends StatelessWidget {
  const QuickActionCard({super.key, required this.action, required this.onTap});

  final QuickActionType action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: action.color.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: action.color.withAlpha(80), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _IconCircle(action: action),
            SizedBox(height: 8.h),
            Text(
              action.label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.action});

  final QuickActionType action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: action.color.withAlpha(50),
      ),
      child: Center(child: Icon(action.icon, color: action.color, size: 22)),
    );
  }
}
