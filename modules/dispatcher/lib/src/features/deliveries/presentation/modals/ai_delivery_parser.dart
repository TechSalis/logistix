import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:dispatcher/src/features/deliveries/presentation/cubit/create_delivery_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistix_ux/logistix_ux.dart';

class AIDeliveryParserDialog extends StatelessWidget {
  const AIDeliveryParserDialog({super.key, this.initialValue});
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(BootstrapSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: LogistixColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: BootstrapSpacing.sm),
                    Text(
                      'AI Delivery Parser',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: BootstrapSpacing.md),
                Text(
                  'Paste WhatsApp messages, emails, or notes to automatically extract delivery details.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(height: BootstrapSpacing.lg),
                _AIDeliveryParserForm(
                  initialValue: initialValue,
                  onSuccess: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close_rounded, color: theme.hintColor, size: 24),
              visualDensity: VisualDensity.compact,
              splashRadius: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _AIDeliveryParserForm extends StatefulWidget {
  const _AIDeliveryParserForm({required this.onSuccess, this.initialValue});
  final String? initialValue;
  final VoidCallback onSuccess;

  @override
  State<_AIDeliveryParserForm> createState() => _AIDeliveryParserFormState();
}

class _AIDeliveryParserFormState extends State<_AIDeliveryParserForm> {
  late final TextEditingController _aiController;

  @override
  void initState() {
    super.initState();
    _aiController = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _aiController.dispose();
    super.dispose();
  }

  Future<void> _copyTemplate() async {
    await context.read<CreateDeliveryCubit>().copyTemplateToClipboard();
    if (mounted) {
      context.toast.showToast(
        'Template copied to clipboard',
        type: ToastType.info,
      );
    }
  }

  Future<void> _pasteFromClipboard() async {
    final text = await context.read<CreateDeliveryCubit>().pasteFromClipboard();
    if (text != null && mounted) {
      setState(() => _aiController.text = text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateDeliveryCubit>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _aiController,
          minLines: 4,
          maxLines: 10,
          decoration: InputDecoration(
            hintText: 'Paste your text here...',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            suffixIcon: ListenableBuilder(
              listenable: _aiController,
              builder: (context, _) {
                if (_aiController.text.isEmpty) {
                  return IconButton(
                    onPressed: _pasteFromClipboard,
                    icon: const Icon(
                      Icons.content_paste_rounded,
                      size: 18,
                      color: LogistixColors.primary,
                    ),
                    tooltip: 'Paste from clipboard',
                  );
                }
                return IconButton(
                  onPressed: _aiController.clear,
                  icon: const Icon(
                    Icons.clear_rounded,
                    size: 18,
                    color: LogistixColors.error,
                  ),
                  tooltip: 'Clear text',
                );
              },
            ),
          ),
        ),
        const SizedBox(height: BootstrapSpacing.md),
        BootstrapButton(
          onPressed: _copyTemplate,
          icon: Icons.copy_rounded,
          label: 'Copy Template',
          type: BootstrapButtonType.text,
        ),
        const SizedBox(height: BootstrapSpacing.md),
        AsyncRunnerListener(
          runner: cubit.parseWithAi,
          listener: (context, state) {
            if (state.status.isSuccess) {
              widget.onSuccess();
            } else if (state.status.isFailure) {
              final error = state.result?.error;
              final message = error is UserError ? error.message : null;
              context.toast.showToast(
                message ?? 'AI parsing failed',
                type: ToastType.error,
              );
              cubit.parseWithAi.reset();
            }
          },
          child: AsyncRunnerBuilder(
            runner: cubit.parseWithAi,
            builder: (context, state, _) {
              return ListenableBuilder(
                listenable: _aiController,
                builder: (context, _) {
                  final text = _aiController.text;
                  final isRunning = state.status.isRunning;
                  return BootstrapButton(
                    label: 'Process Text',
                    icon: Icons.auto_awesome_rounded,
                    isLoading: isRunning,
                    onPressed: text.trim().isEmpty
                        ? null
                        : () {
                            FocusScope.of(context).unfocus();
                            cubit.parseWithAi(text);
                          },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
