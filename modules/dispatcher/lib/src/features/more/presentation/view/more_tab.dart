import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/extensions/string_extension.dart';
import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:dispatcher/src/features/more/presentation/cubit/more_cubit.dart';
import 'package:dispatcher/src/features/more/presentation/widgets/export_options_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:share_plus/share_plus.dart';
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
    final cubit = context.read<MoreCubit>();
    return Scaffold(
      backgroundColor: LogistixColors.background,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: AsyncRunnerListener(
            runner: cubit.exportAnalyticsRunner,
            listener: _handleExportState,
          child: AsyncRunnerListener(
            runner: cubit.exportAnalyticsRunner,
            listener: _handleExportState,
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
                        '(${EnvConfig.instance.environment.capitalizeFirst()})';
                  },
                  orElse: () => 'Loading...',
                );

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: LogistixSpacing.md,
                    ),
                    child: LogistixEntrance(
                      children: [
                        const SizedBox(height: 24),
                        _buildCompanyHeader(state),
                        const SizedBox(height: 32),
                        LogistixSettingsCard(
                          title: 'ANALYTICS & REPORTS',
                          children: [
                            _ExportTile(
                              runner: cubit.exportAnalyticsRunner,
                              icon: Icons.analytics_outlined,
                              title: 'Export Analytics Report',
                              subtitle: 'Includes performance summary and detailed history',
                              onTap: () => _showExportOptions(
                                context,
                                title: 'Export Analytics',
                                showRiderFilter: true,
                                onParamsSelected: cubit.exportAnalyticsRunner,
                              ),
                            ),
                          ],
                        ),
                          const SizedBox(height: 32),
                          LogistixSettingsCard(
                            title: 'SUPPORT & ABOUT',
                            children: [
                              LogistixSettingsTile(
                                icon: Icons.help_outline_rounded,
                                title: 'Help Center',
                                onTap: () =>
                                    _showComingSoon(context, 'Help Center'),
                              ),
                              LogistixSettingsTile(
                                icon: Icons.privacy_tip_outlined,
                                title: 'Privacy Policy',
                                onTap: () =>
                                    _showComingSoon(context, 'Privacy Policy'),
                              ),
                              LogistixSettingsTile(
                                icon: Icons.info_outline,
                                title: 'App Version',
                                subtitle: appVersion,
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          LogistixSettingsCard(
                            children: [
                              LogistixSettingsTile(
                                icon: Icons.logout_rounded,
                                title: 'Logout',
                                titleColor: LogistixColors.error,
                                subtitle: 'Sign out of your account',
                                iconColor: LogistixColors.error,
                                onTap: () => _confirmLogout(context, cubit),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyHeader(MoreState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: state.maybeWhen(
        loading: () {
          return const LogistixShimmer(width: double.infinity, height: 100);
        },
        loaded: (_, company) {
          if (company == null) return const SizedBox();
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                LogistixAvatar(
                  name: company.name,
                  size: 64,
                  backgroundColor: LogistixColors.primary.withValues(
                    alpha: 0.1,
                  ),
                  foregroundColor: LogistixColors.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (company.address != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          company.address!,
                          style: const TextStyle(
                            color: LogistixColors.textSecondary,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        orElse: () => const SizedBox(),
      ),
    );
  }

  Future<void> _showExportOptions(
    BuildContext context, {
    required String title,
    required bool showRiderFilter,
    required AsyncRunnerWithArg<ExportParams, AppError, String>
    onParamsSelected,
  }) async {
    final params = await showGeneralDialog<ExportParams>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'ExportOptions',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      pageBuilder: (context, _, __) => ExportOptionsDialog(
        title: title,
        showRiderFilter: showRiderFilter,
      ),
    );

    if (params != null && context.mounted) {
      await onParamsSelected(params);
    }
  }

  void _handleExportState(
    BuildContext context,
    AsyncState<AppError, String> state,
  ) {
    if (state.status.isSuccess && state.result?.data != null) {
      SharePlus.instance.share(
        ShareParams(
          subject: 'Analytics Export',
          files: [XFile(state.result!.data)],
        ),
      );
    } else if (state.status.isFailure) {
      context.toast.showToast(
        state.result?.error.message ?? 'Export failed',
        type: ToastType.error,
      );
    }
  }

  void _confirmLogout(BuildContext context, MoreCubit cubit) {
    LogistixDialog.show<void>(
      context: context,
      title: 'Logout',
      content: 'Are you sure you want to sign out?',
      icon: Icons.logout_rounded,
      isDestructive: true,
      primaryActionText: 'Logout',
      secondaryActionText: 'Cancel',
      onPrimaryAction: (context) {
        cubit.logout();
        Navigator.pop(context);
      },
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    context.toast.showToast('$feature coming soon', type: ToastType.info);
  }
}

class _ExportTile extends StatelessWidget {
  const _ExportTile({
    required this.runner,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final AsyncRunnerWithArg<ExportParams, AppError, String> runner;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AsyncRunnerBuilder(
      runner: runner,
      builder: (context, state, _) {
        final isLoading = state.status.isRunning;
        return LogistixSettingsTile(
          icon: icon,
          title: title,
          subtitle: subtitle,
          onTap: onTap,
          trailing: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: LogistixColors.primary,
                  ),
                )
              : null,
        );
      },
    );
  }
}
