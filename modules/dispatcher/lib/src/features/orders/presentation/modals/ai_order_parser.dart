import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:dispatcher/src/features/orders/presentation/cubit/create_order_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistix_ux/logistix_ux.dart';

class AIOrderParserDialog extends StatelessWidget {
  const AIOrderParserDialog({super.key, this.initialValue});
  final String? initialValue;

  static Future<void> show(BuildContext context, {String? initialValue}) {
    return BootstrapDialog.show<void>(
      context: context,
      title: 'Order Auto-Fill',
      content: 'Extract details from text',
      icon: Icons.auto_awesome_rounded,
      actionsBuilder: (dialogContext) => [
        _AIOrderParserForm(
          initialValue: initialValue,
          onSuccess: () => Navigator.pop(dialogContext),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // This is now redundant if we use AIOrderParserDialog.show,
    // but kept for compatibility if called directly.
    return _AIOrderParserForm(
      initialValue: initialValue,
      onSuccess: () => Navigator.pop(context),
    );
  }
}

class _AIOrderParserForm extends StatefulWidget {
  const _AIOrderParserForm({required this.onSuccess, this.initialValue});
  final String? initialValue;
  final VoidCallback onSuccess;

  @override
  State<_AIOrderParserForm> createState() => _AIOrderParserFormState();
}

class _AIOrderParserFormState extends State<_AIOrderParserForm> {
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
    await context.read<CreateOrderCubit>().copyTemplateToClipboard();
    if (mounted) {
      context.toast.showToast(
        'Template copied to clipboard',
        type: ToastType.info,
      );
    }
  }

  Future<void> _pasteFromClipboard() async {
    final text = await context.read<CreateOrderCubit>().pasteFromClipboard();
    if (text != null && mounted) {
      setState(() {
        _aiController.text = text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateOrderCubit>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BootstrapTextField(
          controller: _aiController,
          icon: Icons.auto_awesome_rounded,
          lineCount: 4,
          maxLines: 10,
          hintText: 'Paste WhatsApp messages, emails, or notes here...',
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
                );
              }
              return IconButton(
                onPressed: _aiController.clear,
                icon: const Icon(
                  Icons.clear_rounded,
                  size: 18,
                  color: LogistixColors.error,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: BootstrapButton(
            onPressed: _copyTemplate,
            icon: Icons.copy_rounded,
            label: 'Copy Template',
            type: BootstrapButtonType.text,
          ),
        ),
        const SizedBox(height: 16),
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
