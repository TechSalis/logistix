import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProofOfDeliveryDialog extends StatefulWidget {
  const ProofOfDeliveryDialog({required this.deliveryId, super.key});

  final String deliveryId;

  static Future<XFile?> show(BuildContext context, String deliveryId) {
    return BootstrapDialog.show<XFile>(
      context: context,
      title: 'Proof of Delivery',
      content: 'Please take a photo of the package at the delivery location to complete the delivery.',
      actionsBuilder: (dialogContext) => [
        ProofOfDeliveryDialog(deliveryId: deliveryId),
      ],
    );
  }

  @override
  State<ProofOfDeliveryDialog> createState() => _ProofOfDeliveryDialogState();
}

class _ProofOfDeliveryDialogState extends State<ProofOfDeliveryDialog> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool _isProcessing = false;

  Future<void> _takePhoto() async {
    setState(() => _isProcessing = true);
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 70, // High compression as requested
      );
      if (photo != null) {
        setState(() => _image = photo);
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 240,
          width: double.infinity,
          decoration: BoxDecoration(
            color: LogistixColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: LogistixColors.border.withValues(alpha: 0.5),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: _image != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(_image!.path),
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: IconButton(
                        icon: const Icon(LucideIcons.circleX),
                        onPressed: () => setState(() => _image = null),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              : InkWell(
                  onTap: _isProcessing ? null : _takePhoto,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isProcessing)
                        const BootstrapInlineLoader()
                      else ...[
                        const Icon(
                          LucideIcons.camera,
                          size: 48,
                          color: LogistixColors.primary,
                        ),
                        const SizedBox(height: BootstrapSpacing.sm),
                        Text(
                          'Tap to take photo',
                          style: context.textTheme.labelLarge?.bold.copyWith(
                            color: LogistixColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        ),
        const SizedBox(height: BootstrapSpacing.xl),
        Row(
          children: [
            Expanded(
              child: BootstrapButton(
                label: 'Cancel',
                onPressed: () => Navigator.pop(context),
                type: BootstrapButtonType.text,
              ),
            ),
            const SizedBox(width: BootstrapSpacing.md),
            Expanded(
              flex: 2,
              child: BootstrapButton(
                label: 'Confirm Delivery',
                onPressed: _image == null ? null : () => Navigator.pop(context, _image),
                backgroundColor: LogistixColors.success,
                icon: LucideIcons.circleCheck,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
