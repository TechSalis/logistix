import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:dispatcher/src/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistix_ux/logistix_ux.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    required this.onSend,
    required this.onMedia,
    required this.onTyping,
    super.key,
  });

  final Future<void> Function(String) onSend;
  final VoidCallback onMedia;
  final VoidCallback onTyping;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    await widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        BootstrapSpacing.sm,
        BootstrapSpacing.xs,
        BootstrapSpacing.sm,
        MediaQuery.of(context).padding.bottom + BootstrapSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onMedia,
            icon: const Icon(Icons.attach_file),
            color: LogistixColors.textSecondary,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: LogistixColors.surfaceDim,
                borderRadius: BorderRadius.circular(BootstrapRadii.xxl),
              ),
              child: TextField(
                controller: _controller,
                onChanged: (_) => widget.onTyping(),
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: BootstrapSpacing.md,
                    vertical: BootstrapSpacing.xs,
                  ),
                ),
                maxLines: 4,
                minLines: 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _SendButton(
            controller: _controller,
            onPressed: _handleSend,
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.controller, required this.onPressed});
  final TextEditingController controller;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final chatCubit = context.read<ChatCubit>();

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final isTextEmpty = value.text.trim().isEmpty;
        
        return AsyncRunnerBuilder(
          runner: chatCubit.sendMessageRunner,
          builder: (context, runnerState, _) {
            final isLoading = runnerState.status.isRunning;
            
            return IconButton.filled(
              onPressed: (isTextEmpty || isLoading) ? null : onPressed,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send),
              style: IconButton.styleFrom(
                backgroundColor: LogistixColors.primary,
                foregroundColor: Colors.white,
              ),
            );
          },
        );
      },
    );
  }
}
