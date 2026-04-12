import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';

class SendMediaDialog extends StatefulWidget {
  const SendMediaDialog({super.key});

  static Future<({String url, String? caption})?> show(BuildContext context) {
    return showDialog<({String url, String? caption})>(
      context: context,
      builder: (context) => const SendMediaDialog(),
    );
  }

  @override
  State<SendMediaDialog> createState() => _SendMediaDialogState();
}

class _SendMediaDialogState extends State<SendMediaDialog> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Send Media'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              hintText: 'Image URL',
              labelText: 'Image URL',
            ),
            keyboardType: TextInputType.url,
            autofocus: true,
          ),
          const SizedBox(height: BootstrapSpacing.md),
          TextField(
            controller: _captionController,
            decoration: const InputDecoration(
              hintText: 'Caption (optional)',
              labelText: 'Caption',
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final url = _urlController.text.trim();
            if (url.isEmpty) return;
            
            Navigator.pop(context, (
              url: url,
              caption: _captionController.text.trim().isEmpty 
                  ? null 
                  : _captionController.text.trim(),
            ));
          },
          child: const Text('Send'),
        ),
      ],
    );
  }
}
