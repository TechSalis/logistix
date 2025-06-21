import 'package:flutter/material.dart';

class FormCard extends StatelessWidget {
  const FormCard({
    super.key,
    required this.title,
    required this.child,
    this.error,
    this.isRequired = true,
  });

  final bool isRequired;
  final Widget child;
  final String title;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: isRequired ? 2 : .5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: isRequired ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                Spacer(),
                if (error != null)
                  Text(
                    error!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
