import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:rider/src/presentation/bloc/rider_bloc.dart';
import 'package:rider/src/presentation/bloc/rider_state.dart';
import 'package:shared/shared.dart';

class RiderLockedPage extends StatelessWidget {
  const RiderLockedPage({required this.onRefresh, super.key});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RiderBloc, RiderState>(
      listener: (context, state) {
        state.whenOrNull(
          error: (message) {
            context.toast.showToast(message, type: ToastType.error);
          },
        );
      },
      builder: (context, state) {
        final isLoading = state.maybeMap(
          loading: (_) => true,
          orElse: () => false,
        );

        final bloc = context.read<RiderBloc>();
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_person_outlined,
                    size: 100,
                    color: LogistixColors.primary,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Account Pending Approval',
                    style: context.textTheme.headlineMedium?.bold,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your account is currently waiting for company approval. Once approved, you will be able to access your dashboard and start receiving orders.',
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: LogistixColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  LogistixButton(
                    onPressed: onRefresh,
                    isLoading: isLoading,
                    icon: Icons.refresh_rounded,
                    label: 'REFRESH STATUS',
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LogistixButton(
                        onPressed: bloc.logout,
                        icon: Icons.logout_rounded,
                        label: 'LOGOUT',
                        type: LogistixButtonType.text,
                        width: 140,
                      ),
                      const SizedBox(width: 8),
                      AsyncRunnerListener(
                        runner: bloc.supportRunner,
                        listener: (context, state) {
                          if (state.status.isFailure) {
                            context.toast.showToast(
                              state.result?.error.message ?? 'Support failed',
                              type: ToastType.error,
                            );
                          }
                        },
                        child: LogistixButton(
                          onPressed: () {
                            bloc.supportRunner(EnvConfig.contactSupportUrl);
                          },
                          label: 'SUPPORT',
                          type: LogistixButtonType.text,
                          width: 140,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
