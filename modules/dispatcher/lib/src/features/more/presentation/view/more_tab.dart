import 'package:bootstrap/extensions/string_extension.dart';
import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:dispatcher/src/features/more/presentation/cubit/more_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class MoreTab extends StatelessWidget {
  const MoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<MoreCubit>().loadAppInfo();
    return const _MoreView();
  }
}

class _MoreView extends StatelessWidget {
  const _MoreView();

  @override
  Widget build(BuildContext context) {
    final logoutEvent = context.read<MoreCubit>().logoutEvent;
    return Scaffold(
      body: SafeArea(
        child: AsyncRunnerListener(
          runner: logoutEvent,
          listener: (context, state) {
            if (state.status.isSuccess) {
              context.go(ModuleRoutePaths.auth);
            }
          },
          child: BlocConsumer<MoreCubit, MoreState>(
            listener: (context, state) {
              state.whenOrNull(
                error: (message) {
                  context.toast.showToast(message, type: ToastType.error);
                },
              );
            },
            builder: (context, state) {
              final appVersion = state.maybeMap(
                loaded: (state) {
                  return '${state.packageInfo.version} '
                      '(${EnvConfig.environment.capitalizeFirst()})';
                },
                orElse: () => 'Loading...',
              );

              final company = state.mapOrNull(loaded: (state) => state.company);

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Company Profile Section
                  if (company != null) ...[
                    Card(
                      shape: const RoundedRectangleBorder(
                        borderRadius: LogistixRadii.borderRadiusCard,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: LogistixColors.primary
                                  .withValues(alpha: 0.1),
                              child: const Icon(
                                Icons.business_rounded,
                                color: LogistixColors.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    company.name,
                                    style:
                                        context.textTheme.titleMedium?.semiBold,
                                  ),
                                  if (company.address != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      company.address!,
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: LogistixColors.textSecondary,
                                          ),
                                    ),
                                  ],
                                  if (company.phoneNumber != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      company.phoneNumber!,
                                      style: context.textTheme.bodySmall
                                          ?.copyWith(
                                            color: LogistixColors.textSecondary,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  Text(
                    'Support & About',
                    style: context.textTheme.titleSmall?.copyWith(
                      color: LogistixColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    shape: const RoundedRectangleBorder(
                      borderRadius: LogistixRadii.borderRadiusCard,
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.help_outline_rounded,
                            color: LogistixColors.primary,
                          ),
                          title: const Text('Help Center'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            context.toast.showToast(
                              'Help Center coming soon',
                              type: ToastType.info,
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.privacy_tip_outlined,
                            color: LogistixColors.primary,
                          ),
                          title: const Text('Privacy Policy'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            context.toast.showToast(
                              'Privacy Policy coming soon',
                              type: ToastType.info,
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.article_outlined,
                            color: LogistixColors.primary,
                          ),
                          title: const Text('Terms of Service'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            context.toast.showToast(
                              'Terms of Service coming soon',
                              type: ToastType.info,
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.info_outline,
                            color: LogistixColors.primary,
                          ),
                          title: const Text('App version'),
                          subtitle: Text(appVersion),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    shape: const RoundedRectangleBorder(
                      borderRadius: LogistixRadii.borderRadiusCard,
                    ),
                    // Use a slightly different styling for Logout to make it stand out
                    // without being overly aggressive.
                    child: ListTile(
                      leading: const Icon(
                        Icons.logout_rounded,
                        color: LogistixColors.error,
                      ),
                      title: const Text(
                        'Logout',
                        style: TextStyle(
                          color: LogistixColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () {
                        LogistixDialog.show<void>(
                          context: context,
                          title: 'Logout',
                          content: 'Are you sure you want to sign out?',
                          icon: Icons.logout_rounded,
                          isDestructive: true,
                          primaryActionText: 'Logout',
                          secondaryActionText: 'Cancel',
                          onPrimaryAction: () {
                            Navigator.pop(context);
                            logoutEvent();
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
