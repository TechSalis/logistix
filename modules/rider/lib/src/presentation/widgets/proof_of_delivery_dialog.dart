import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared/shared.dart';

class ProofOfDeliveryDialog extends StatefulWidget {
  const ProofOfDeliveryDialog({required this.orderId, super.key});

  final String orderId;

  static Future<XFile?> show(BuildContext context, String orderId) {
    return showDialog<XFile>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProofOfDeliveryDialog(orderId: orderId),
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
    return BootstrapDialog(
      title: 'Proof of Delivery',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Please take a photo of the package at the delivery location to complete the order.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: BootstrapSpacing.lg),
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
                        child: CircleIconButton(
                          icon: LucideIcons.x,
                          onPressed: () => setState(() => _image = null),
                          backgroundColor: Colors.black54,
                          iconColor: Colors.white,
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
        ],
      ),
      actions: [
        BootstrapButton(
          label: 'Cancel',
          onPressed: () => Navigator.pop(context),
          variant: BootstrapButtonVariant.ghost,
        ),
        BootstrapButton(
          label: 'Confirm Delivery',
          onPressed: _image == null ? null : () => Navigator.pop(context, _image),
          backgroundColor: LogistixColors.success,
          icon: LucideIcons.checkCircle,
        ),
      ],
    );
  }
}
