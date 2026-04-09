import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/extensions/string_extension.dart';
import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:dispatcher/src/features/more/presentation/cubit/more_cubit.dart';
import 'package:dispatcher/src/features/more/presentation/widgets/export_options_bottom_sheet.dart';
import 'package:dispatcher/src/features/more/presentation/widgets/platform_picker_sheet.dart';
import 'package:dispatcher/src/features/more/presentation/widgets/platform_widgets.dart';
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
    final cubit = context.read<MoreCubit>()..loadAppInfo();
    return Scaffold(
      backgroundColor: LogistixColors.background,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
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

                final user = state.whenOrNull(loaded: (_, user) => user);

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: LogistixSpacing.md,
                    ),
                    child: LogistixEntrance(
                      children: [
                        const SizedBox(height: 24),
                        _buildProfileHeader(state),
                        const SizedBox(height: 32),
                        LogistixSettingsCard(
                          title: 'AI & INTEGRATIONS',
                          children: [
                            LogistixSettingsTile(
                              icon: Icons.rocket_launch_outlined,
                              title: 'AI Automation',
                              iconColor: LogistixColors.primary,
                              titleColor: LogistixColors.primary,
                              subtitle: _getIntegrationsSummary(user),
                              onTap: () => _showPlatformPicker(context, state),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        LogistixSettingsCard(
                          title: 'DATA EXPORT',
                          children: [
                            ExportTile(
                              runner: cubit.exportAnalyticsRunner,
                              icon: Icons.analytics_outlined,
                              title: 'Analytics Export',
                              subtitle: 'Export performance metrics',
                              onTap: () => _showExportOptions(
                                context,
                                title: 'Export Analytics',
                                showRiderFilter: false,
                                onParamsSelected: cubit.exportAnalyticsRunner,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        LogistixSettingsCard(
                          title: 'SUPPORT & LEGAL',
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
    );
  }

  Widget _buildProfileHeader(MoreState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: state.maybeWhen(
        loading: () {
          return const LogistixShimmer(width: double.infinity, height: 100);
        },
        loaded: (_, user) {
          if (user == null) return const SizedBox();
          final company = user.companyProfile;
          return LogistixCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                LogistixAvatar(
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
    final params = await showModalBottomSheet<ExportParams>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return ExportOptionsSheet(
          title: title,
          showRiderFilter: showRiderFilter,
        );
      },
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
      type: LogistixDialogType.destructive,
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

  void _showPlatformPicker(BuildContext context, MoreState state) {
    final moreCubit = context.read<MoreCubit>();
    final toastService = ToastServiceProvider.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => PlatformPickerSheet(
        state: state,
        onPlatformSelected: (platform) {
          if (platform == Platform.whatsapp) {
            Navigator.pop(context);
            _showRequestDialog(
              context,
              toastService,
              moreCubit.requestIntegrationRunner,
              platform,
              state,
            );
          } else {
            _showComingSoon(context, platform.name.capitalizeFirst());
          }
        },
      ),
    );
  }

  void _showRequestDialog(
    BuildContext context,
    IToastService service,
    AsyncRunnerWithArg<ActivationRequestDto, AppError, void> runner,
    Platform platform,
    MoreState state,
  ) {
    state.whenOrNull(
      loaded: (info, user) {
        LogistixDialog.show<void>(
          context: context,
          title: 'Activate ${platform.name.capitalizeFirst()}',
          content: 'Fill in your contact details for activation.',
          icon: Icons.rocket_launch_outlined,
          actionsBuilder: (dialogContext) {
            return [
              ToastServiceProvider(
                service: service,
                child: PlatformActivationForm(
                  platform: platform,
                  user: user,
                  runner: runner,
                  onSuccess: () => Navigator.pop(dialogContext),
                ),
              ),
            ];
          },
        );
      },
    );
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
      return 'Setup pending for ${integrations.length} channels';
    }

    return 'Active: ${active.join(", ")}';
  }
}
