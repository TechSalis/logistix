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
                        _buildProfileHeader(state),
                        const SizedBox(height: 32),
                        LogistixSettingsCard(
                          title: 'ANALYTICS & REPORTS',
                          children: [
                            _ExportTile(
                              runner: cubit.exportAnalyticsRunner,
                              icon: Icons.analytics_outlined,
                              title: 'Export Analytics Report',
                              subtitle:
                                  'Includes performance summary and detailed history',
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
                          title: 'AI & INTEGRATIONS',
                          children: [
                            LogistixSettingsTile(
                              icon: Icons.hub_outlined,
                              title: 'Connect Platforms',
                              subtitle: _getIntegrationsSummary(
                                state,
                                state.maybeWhen(
                                  loaded: (_, user) => user,
                                  orElse: () => null,
                                ),
                              ),
                              onTap: () => _showPlatformPicker(context, state),
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
    );
  }

  Widget _buildProfileHeader(MoreState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: state.maybeWhen(
        loading: () =>
            const LogistixShimmer(width: double.infinity, height: 100),
        loaded: (_, user) {
          if (user == null) return const SizedBox();
          final company = user.companyProfile;
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

  void _showPlatformPicker(BuildContext context, MoreState state) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PlatformPickerSheet(
        state: state,
        onPlatformSelected: (platform) {
          if (platform.toLowerCase() == 'whatsapp') {
            Navigator.pop(context);
            _showRequestDialog(context, platform, state);
          } else {
            _showComingSoon(context, platform);
          }
        },
      ),
    );
  }

  void _showRequestDialog(
    BuildContext context,
    String platform,
    MoreState state,
  ) {
    state.maybeWhen(
      loaded: (info, user) {
        final emailCtrl = TextEditingController(text: user?.email ?? '');
        final nameCtrl = TextEditingController(
          text: user?.companyProfile?.name ?? user?.fullName ?? '',
        );
        final phoneCtrl = TextEditingController(text: user?.phoneNumber ?? '');

        LogistixDialog.show<void>(
          context: context,
          title: 'Activate $platform',
          content: 'Fill in your contact details for activation.',
          icon: Icons.rocket_launch_outlined,
          primaryActionText: 'Request Activation',
          actions: [
            LogistixTextField(
              label: 'Business Name',
              controller: nameCtrl,
              icon: Icons.business,
            ),
            const SizedBox(height: 12),
            LogistixTextField(
              label: 'Contact Email',
              controller: emailCtrl,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            LogistixTextField(
              label: 'Contact Phone',
              controller: phoneCtrl,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              hintText: '+234...',
            ),
            const SizedBox(height: 24),
            LogistixButton(
              label: 'Request Activation',
              onPressed: () {
                context.read<MoreCubit>().requestIntegrationRunner(
                  ActivationRequestDto(
                    email: emailCtrl.text,
                    name: nameCtrl.text,
                    phone: phoneCtrl.text,
                    platform: platform.toLowerCase(),
                  ),
                );
                Navigator.pop(context);
                context.toast.showToast(
                  'Request sent!',
                  type: ToastType.success,
                );
              },
            ),
          ],
          onPrimaryAction:
              (context) {}, // Handled by button in actions for custom layout
        );
      },
      orElse: () {},
    );
  }
}

class _PlatformPickerSheet extends StatelessWidget {
  const _PlatformPickerSheet({
    required this.state,
    required this.onPlatformSelected,
  });

  final MoreState state;
  final void Function(String) onPlatformSelected;

  @override
  Widget build(BuildContext context) {
    return _buildPlatformPicker(context, state);
  }

  Widget _buildPlatformPicker(BuildContext context, MoreState state) {
    final user = state.maybeWhen(loaded: (_, user) => user, orElse: () => null);
    final integrations = user?.companyProfile?.integrations ?? [];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Connect AI Platforms',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select a channel to automate your logistics with Logistix AI.',
            style: TextStyle(color: LogistixColors.textSecondary),
          ),
          const SizedBox(height: 24),
          _PlatformTile(
            icon: Icons.message,
            title: 'WhatsApp Business',
            subtitle: _getPlatformStatus(integrations, Platform.whatsapp),
            color: const Color(0xFF25D366),
            isActive: _isPlatformActive(integrations, Platform.whatsapp),
            onTap: () => onPlatformSelected('WhatsApp'),
          ),
          _PlatformTile(
            icon: Icons.camera_alt_outlined,
            title: 'Instagram DM',
            subtitle: _getPlatformStatus(integrations, Platform.instagram),
            color: const Color(0xFFE4405F),
            enabled: false,
            onTap: () => onPlatformSelected('Instagram'),
          ),
          _PlatformTile(
            icon: Icons.facebook,
            title: 'Facebook Messenger',
            subtitle: _getPlatformStatus(integrations, Platform.facebook),
            color: const Color(0xFF1877F2),
            enabled: false,
            onTap: () => onPlatformSelected('Facebook'),
          ),
          _PlatformTile(
            icon: Icons.music_note,
            title: 'TikTok',
            subtitle: _getPlatformStatus(integrations, Platform.tiktok),
            color: Colors.black,
            enabled: false,
            onTap: () => onPlatformSelected('TikTok'),
          ),
        ],
      ),
    );
  }

  String _getPlatformStatus(
    List<CompanyIntegration> integrations,
    Platform platform,
  ) {
    final integration = integrations
        .where((e) => e.platform == platform)
        .firstOrNull;
    if (integration == null) return 'The #1 channel for customer orders';
    return integration.isActive ? 'Active & Connected' : 'Setup in progress...';
  }

  bool _isPlatformActive(
    List<CompanyIntegration> integrations,
    Platform platform,
  ) {
    return integrations.any((e) => e.platform == platform && e.isActive);
  }
}

String _getIntegrationsSummary(MoreState state, User? user) {
  final integrations = user?.companyProfile?.integrations ?? [];
  if (integrations.isEmpty)
    return 'Link WhatsApp, Facebook, & TikTok to your AI';

  final active = integrations
      .where((e) => e.isActive)
      .map((e) => e.platform.name.capitalizeFirst())
      .toList();

  if (active.isEmpty)
    return 'Setup pending for ${integrations.length} channels';

  return 'Active: ${active.join(", ")}';
}

class _PlatformTile extends StatelessWidget {
  const _PlatformTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.enabled = true,
    this.isActive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: isActive
            ? const Icon(Icons.check_circle, color: LogistixColors.primary)
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
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
