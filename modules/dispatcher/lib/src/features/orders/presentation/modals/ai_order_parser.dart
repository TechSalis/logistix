import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:dispatcher/src/features/orders/presentation/cubit/create_order_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';

class AIOrderParserDialog extends StatefulWidget {
  const AIOrderParserDialog({super.key, this.initialValue});
  final String? initialValue;

  @override
  State<AIOrderParserDialog> createState() => _AIOrderParserDialogState();
}

class _AIOrderParserDialogState extends State<AIOrderParserDialog> {
  final _aiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _aiController.text = widget.initialValue ?? '';
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
    final textTheme = context.textTheme;

    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: LogistixColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: LogistixColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Order Parser',
                        style: textTheme.titleLarge?.bold,
                      ),
                      Text(
                        'Extract details from text',
                        style: textTheme.bodySmall?.copyWith(
                          color: LogistixColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(
                    foregroundColor: LogistixColors.text,
                    backgroundColor: LogistixColors.neutral100,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Stack(
              children: [
                TextField(
                  maxLines: 5,
                  controller: _aiController,
                  style: textTheme.bodyMedium?.semiBold,
                  decoration: InputDecoration(
                    hintText:
                        'Paste WhatsApp messages, emails, or notes here...',
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: LogistixColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: LogistixColors.background,
                    contentPadding: const EdgeInsets.all(20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: LogistixColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: ListenableBuilder(
                    listenable: _aiController,
                    builder: (context, _) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_aiController.text.isNotEmpty)
                            IconButton(
                              onPressed: _aiController.clear,
                              icon: const Icon(
                                Icons.clear_rounded,
                                size: 18,
                                color: LogistixColors.error,
                              ),
                            ),
                          IconButton(
                            onPressed: _pasteFromClipboard,
                            icon: const Icon(
                              Icons.content_paste_rounded,
                              size: 18,
                              color: LogistixColors.primary,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: LogistixButton(
                onPressed: _copyTemplate,
                icon: Icons.copy_rounded,
                label: 'Copy Template',
                type: LogistixButtonType.text,
              ),
            ),
            const SizedBox(height: 16),
            AsyncRunnerListener(
              runner: context.read<CreateOrderCubit>().parseWithAi,
              listener: (context, state) {
                if (state.status.isSuccess) {
                  context.pop();
                } else if (state.status.isFailure) {
                  final error = state.result?.error;
                  final message = error is UserError ? error.message : null;
                  context.toast.showToast(
                    message ?? 'AI parsing failed',
                    type: ToastType.error,
                  );
                  context.read<CreateOrderCubit>().parseWithAi.reset();
                }
              },
              child: AsyncRunnerBuilder(
                runner: context.read<CreateOrderCubit>().parseWithAi,
                builder: (context, state, _) {
                  return ListenableBuilder(
                    listenable: _aiController,
                    builder: (context, _) {
                      final text = _aiController.text;
                      final isRunning = state.status.isRunning;
                      return LogistixButton(
                        label: 'Process Text',
                        isLoading: isRunning,
                        onPressed: text.trim().isEmpty
                            ? null
                            : () {
                                FocusScope.of(context).unfocus();
                                context.read<CreateOrderCubit>().parseWithAi(
                                  text,
                                );
                              },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
