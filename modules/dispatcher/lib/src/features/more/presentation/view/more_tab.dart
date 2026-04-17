import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:dispatcher/src/features/more/presentation/cubit/more_cubit.dart';
import 'package:dispatcher/src/features/more/presentation/widgets/export_options_bottom_sheet.dart';
import 'package:dispatcher/src/features/more/presentation/widgets/platform_widgets.dart';
import 'package:dispatcher/src/presentation/router/dispatcher_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared/shared.dart';

class MoreTab extends StatelessWidget {
  const MoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MoreCubit>()..loadAppInfo();
    return Scaffold(
      backgroundColor: LogistixColors.background,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: AsyncRunnerListener(
            runner: cubit.logoutRunner,
            listener: (context, state) {
              if (state.status.isFailure) {
                context.toast.showToast(
                  state.result?.error.message ?? 'Logout failed',
                  type: ToastType.error,
                );
              }
            },
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
                  final appVersion = state.maybeWhen(
                    loaded: (packageInfo, _) {
                      final environment = EnvConfig.instance.environment;
                      return '${packageInfo.version}'
                          '${environment == 'production' ? '' : ' (${environment.capitalizeFirst()})'}';
                    },
                    orElse: () => 'Loading...',
                  );

                  final user = state.whenOrNull(loaded: (_, user) => user);

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: BootstrapSpacing.md,
                      ),
                      child: BootstrapEntrance(
                        children: [
                          const SizedBox(height: 24),
                          _buildProfileHeader(state),
                          const SizedBox(height: 32),
                          BootstrapSettingsCard(
                            title: 'INTEGRATIONS',
                            children: [
                              BootstrapSettingsTile(
                                icon: Icons.rocket_launch_outlined,
                                title: 'Platform Automation',
                                iconColor: LogistixColors.primary,
                                titleColor: LogistixColors.primary,
                                subtitle: _getIntegrationsSummary(user),
                                onTap: () => context.push(
                                  DispatcherRoutes.requestIntegration,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          BootstrapSettingsCard(
                            title: 'DATA EXPORT',
                            children: [
                              ExportTile(
                                runner: cubit.exportAnalyticsRunner,
                                icon: Icons.analytics_outlined,
                                title: 'Orders Export',
                                subtitle: 'Export orders and metrics',
                                onTap: () => _showExportOptions(
                                  context,
                                  title: 'Export Your Orders',
                                  showRiderFilter: true,
                                  onParamsSelected: cubit.exportAnalyticsRunner,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          BootstrapSettingsCard(
                            title: 'SUPPORT & LEGAL',
                            children: [
                              BootstrapSettingsTile(
                                icon: Icons.help_outline_rounded,
                                title: 'Help Center',
                                onTap: () =>
                                    _showComingSoon(context, 'Help Center'),
                              ),
                              BootstrapSettingsTile(
                                icon: Icons.privacy_tip_outlined,
                                title: 'Privacy Policy',
                                onTap: () =>
                                    _showComingSoon(context, 'Privacy Policy'),
                              ),
                              BootstrapSettingsTile(
                                icon: Icons.info_outline,
                                title: 'App Version',
                                subtitle: appVersion,
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          BootstrapSettingsCard(
                            children: [
                              BootstrapSettingsTile(
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

  Widget _buildProfileHeader(MoreState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: state.maybeWhen(
        loading: () {
          return const BootstrapShimmer(width: double.infinity, height: 100);
        },
        loaded: (_, user) {
          if (user == null) return const SizedBox();
          final company = user.companyProfile;
          return BootstrapCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                BootstrapAvatar(
                  name: company?.name ?? user.fullName,
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
                        company?.name ?? user.fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        company?.address ?? user.email,
                        style: const TextStyle(
                          color: LogistixColors.textSecondary,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
    final params = await ExportOptionsSheet.show(
      context,
      title: title,
      showRiderFilter: showRiderFilter,
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
          files: [XFile(state.result!.data)],
          subject: 'Orders Export',
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
    LogoutConfirmationDialog.show(context, onLogout: cubit.logoutRunner.call);
  }

  void _showComingSoon(BuildContext context, String feature) {
    context.toast.showToast('$feature coming soon', type: ToastType.info);
  }

  String _getIntegrationsSummary(User? user) {
    final integrations = user?.companyProfile?.integrations ?? [];
    if (integrations.isEmpty) {
      return 'Link WhatsApp, Facebook, & TikTok to your AI';
    }

    final active = integrations
        .where((e) => e.isActive)
        .map((e) => e.platform.name.capitalizeFirst())
        .toList();

    if (active.isEmpty) {
      return 'Setup pending for ${integrations.length} '
          '${'channel'.pluralize(count: integrations.length)}';
    }

    return 'Active: ${active.join(", ")}';
  }
}
