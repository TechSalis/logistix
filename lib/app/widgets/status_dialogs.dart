import 'package:flutter/material.dart';

class AppDialog extends StatelessWidget {
  final Widget icon;
  final String title;
  final String? message;
  final Widget? content;
  final List<Widget> actions;
  final EdgeInsetsGeometry padding;

  const AppDialog({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.content,
    required this.actions,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (content != null) ...[const SizedBox(height: 16), content!],
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
}


Future<void> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required Widget confirmButton,
}) {
  return showDialog(
    context: context,
    builder: (_) {
      return AppDialog(
        icon: const Icon(Icons.help_outline, size: 40, color: Colors.orange),
        title: title,
        message: message,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          confirmButton,
        ],
      );
    },
  );
}

Future<void> showSuccessDialog(
  BuildContext context, {
  required String title,
  String? message,
}) {
  return showDialog(
    context: context,
    builder:
        (_) => AppDialog(
          icon: const Icon(Icons.check_circle, size: 48, color: Colors.green),
          title: title,
          message: message,
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
  );
}

Future<void> showErrorDialog(
  BuildContext context, {
  required String title,
  String? message,
}) {
  return showDialog(
    context: context,
    builder:
        (_) => AppDialog(
          icon: const Icon(Icons.error, size: 48, color: Colors.red),
          title: title,
          message: message,
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
  );
}

// void showLoadingDialog(BuildContext context, {String? message}) {
//   showDialog(
//     barrierDismissible: false,
//     context: context,
//     builder:
//         (_) => Dialog(
//           backgroundColor: Theme.of(context).colorScheme.surface,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(24),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const CircularProgressIndicator(),
//                 if (message != null) ...[
//                   const SizedBox(height: 16),
//                   Text(message, textAlign: TextAlign.center),
//                 ],
//               ],
//             ),
//           ),
//         ),
//   );
// }
