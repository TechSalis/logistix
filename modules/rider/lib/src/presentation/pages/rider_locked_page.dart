import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:rider/src/presentation/bloc/rider_bloc.dart';
import 'package:rider/src/presentation/bloc/rider_state.dart';
import 'package:shared/shared.dart';

class RiderLockedPage extends StatelessWidget {
  const RiderLockedPage({
    required this.onRefresh,
    this.isRefreshing = false,
    super.key,
  });

  final VoidCallback onRefresh;
  final bool isRefreshing;

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
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        final bloc = context.read<RiderBloc>();
        final logoutEvent = bloc.logoutEvent;
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
                  SizedBox(
                    height: 48,
                    child: Center(
                      child: isRefreshing
                          ? const LogistixInlineLoader()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: onRefresh,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Refresh Status'),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AsyncRunnerListener(
                        runner: logoutEvent,
                        listener: (context, state) {
                          state.result?.map((error) {
                            if (error is UserError && error.message != null) {
                              context.toast.showToast(
                                error.message!,
                                type: ToastType.error,
                              );
                            }
                          }, (_) => context.go(ModuleRoutePaths.auth));
                        },
                        child: TextButton.icon(
                          onPressed: isLoading ? null : logoutEvent.call,
                          icon: isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: LogistixColors.error,
                                  ),
                                )
                              : const Icon(
                                  Icons.logout,
                                  color: LogistixColors.error,
                                ),
                          label: Text(
                            'Logout',
                            style: context.textTheme.labelLarge?.copyWith(
                              color: LogistixColors.error,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AsyncRunnerListener(
                        runner: bloc.supportRunner,
                        listener: (context, state) {
                          state.result?.when(
                            error: (error) {
                              if (error is UserError && error.message != null) {
                                context.toast.showToast(
                                  error.message!,
                                  type: ToastType.error,
                                );
                              }
                            },
                          );
                        },
                        child: TextButton(
                          onPressed: () {
                            bloc.supportRunner(EnvConfig.contactSupportUrl);
                          },
                          child: const Text('Contact Support'),
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
