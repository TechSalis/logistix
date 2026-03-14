import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:dispatcher/src/features/orders/presentation/cubit/create_order_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';

class AIOrderParserBottomSheet extends StatefulWidget {
  const AIOrderParserBottomSheet({super.key, this.initialValue});
  final String? initialValue;

  @override
  State<AIOrderParserBottomSheet> createState() =>
      _AIOrderParserBottomSheetState();
}

class _AIOrderParserBottomSheetState extends State<AIOrderParserBottomSheet> {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.rocket_launch_rounded,
                color: LogistixColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Order Parser',
                style: context.textTheme.titleLarge?.bold,
              ),
              const Spacer(),
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Paste unstructured text from WhatsApp, email or notes, and we'll extract order details for you.",
            style: TextStyle(color: LogistixColors.textSecondary),
          ),
          const SizedBox(height: 20),
          TextField(
            maxLines: 5,
            controller: _aiController,
            decoration: InputDecoration(
              hintText:
                  'e.g. John Doe, 08012345678, at 5 Lekki Phase 1, NGN 5000',
              filled: true,
              fillColor: LogistixColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
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
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: text.isEmpty || state.status.isRunning
                            ? null
                            : () => context
                                  .read<CreateOrderCubit>()
                                  .parseWithAi(text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: LogistixColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: state.status.isRunning
                            ? const LogistixInlineLoader(color: Colors.white)
                            : const Text(
                                'Parse Text',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
