import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:collection/collection.dart';
import 'package:dispatcher/src/core/extensions/chat_platform_extension.dart';
import 'package:dispatcher/src/features/more/presentation/cubit/more_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class PlatformPickerSheet extends StatefulWidget {
  const PlatformPickerSheet({
    required this.state,
    required this.onPlatformSelected,
    super.key,
  });

  final MoreState state;
  final void Function(ChatPlatform) onPlatformSelected;

  @override
  State<PlatformPickerSheet> createState() => _PlatformPickerSheetState();
}

class _PlatformPickerSheetState extends State<PlatformPickerSheet> {
  @override
  void initState() {
    super.initState();
    // Fetch fresh integrations when the sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoreCubit>().fetchIntegrationsRunner();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MoreCubit>();
    final runner = cubit.fetchIntegrationsRunner;

    return SizedBox(
      height: 500,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          BootstrapSpacing.lg,
          0,
          BootstrapSpacing.lg,
          BootstrapSpacing.xl,
        ),
        child: AsyncRunnerBuilder(
          runner: runner,
          builder: (context, runnerState, _) {
            return widget.state.maybeWhen(
              loaded: (_, user) {
                final integrations =
                    user?.companyProfile?.integrations ??
                    <CompanyIntegration>[];

                if (runnerState.status.isRunning && integrations.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: BootstrapSpacing.xxxl,
                      ),
                      child: BootstrapInlineLoader(),
                    ),
                  );
                }

                if (runnerState.status.isFailure && integrations.isEmpty) {
                  return _buildErrorState(runner);
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(BootstrapSpacing.sm),
                          decoration: BoxDecoration(
                            color: LogistixColors.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(
                              BootstrapRadii.lg,
                            ),
                          ),
                          child: const Icon(
                            Icons.hub_outlined,
                            color: LogistixColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: BootstrapSpacing.md),
                        Expanded(
                          child: Text(
                            'Connect Platforms',
                            style: context.textTheme.titleLarge?.semiBold,
                          ),
                        ),
                        if (runnerState.status.isRunning)
                          const BootstrapInlineLoader(size: 16),
                      ],
                    ),
                    const SizedBox(height: BootstrapSpacing.md),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text:
                                'Select a channel to automate your logistics with ',
                          ),
                          TextSpan(
                            text: '${ProjectConfig.brandName} Automation.',
                            style: context.textTheme.bodyMedium?.semiBold,
                          ),
                        ],
                      ),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: LogistixColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: BootstrapSpacing.lg),
                    if (runnerState.status.isFailure)
                      _buildInlineError(
                        runnerState.result?.error.message ?? 'Refresh failed',
                        runner,
                      ),
                    _PlatformTile(
                      leading: ChatPlatform.WHATSAPP.icon(),
                      title: 'WhatsApp Business',
                      subtitle: _getPlatformStatus(
                        integrations,
                        ChatPlatform.WHATSAPP,
                      ),
                      color: const Color(0xFF25D366),
                      isActive: _isPlatformActive(
                        integrations,
                        ChatPlatform.WHATSAPP,
                      ),
                      isPending: _isPlatformPending(
                        integrations,
                        ChatPlatform.WHATSAPP,
                      ),
                      onTap: () =>
                          widget.onPlatformSelected(ChatPlatform.WHATSAPP),
                    ),
                    _PlatformTile(
                      leading: ChatPlatform.INSTAGRAM.icon(),
                      title: 'Instagram DM',
                      subtitle: _getPlatformStatus(
                        integrations,
                        ChatPlatform.INSTAGRAM,
                      ),
                      color: const Color(0xFFE4405F),
                      enabled: false,
                      onTap: () =>
                          widget.onPlatformSelected(ChatPlatform.INSTAGRAM),
                    ),
                    _PlatformTile(
                      leading: ChatPlatform.FACEBOOK.icon(),
                      title: 'Facebook Messenger',
                      subtitle: _getPlatformStatus(
                        integrations,
                        ChatPlatform.FACEBOOK,
                      ),
                      color: const Color(0xFF1877F2),
                      enabled: false,
                      onTap: () =>
                          widget.onPlatformSelected(ChatPlatform.FACEBOOK),
                    ),
                    _PlatformTile(
                      leading: ChatPlatform.TIKTOK.icon(),
                      title: 'TikTok Automation',
                      subtitle: _getPlatformStatus(
                        integrations,
                        ChatPlatform.TIKTOK,
                      ),
                      color: Colors.black,
                      enabled: false,
                      onTap: () =>
                          widget.onPlatformSelected(ChatPlatform.TIKTOK),
                    ),
                  ],
                );
              },
              orElse: () => const SizedBox(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(AsyncRunner<dynamic, dynamic> runner) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: BootstrapSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: LogistixColors.error,
            ),
            const SizedBox(height: BootstrapSpacing.lg),
            Text(
              'Failed to load integrations',
              style: context.textTheme.bodyLarge,
            ),
            const SizedBox(height: BootstrapSpacing.xs),
            BootstrapButton(
              label: 'Try Again',
              onPressed: () => runner(),
              type: BootstrapButtonType.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineError(
    String message,
    AsyncRunner<dynamic, dynamic> runner,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BootstrapSpacing.lg),
      child: InkWell(
        onTap: () => runner(),
        child: Container(
          padding: const EdgeInsets.all(BootstrapSpacing.md),
          decoration: BoxDecoration(
            color: LogistixColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(BootstrapRadii.lg),
          ),
          child: Row(
            children: [
              const Icon(Icons.refresh, size: 16, color: LogistixColors.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: LogistixColors.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPlatformStatus(
    List<CompanyIntegration> integrations,
    ChatPlatform platform,
  ) {
    final integration = integrations.firstWhereOrNull(
      (e) => e.platform == platform,
    );

    if (integration == null) {
      return switch (platform) {
        ChatPlatform.WHATSAPP => 'Automate orders from WhatsApp+',
        ChatPlatform.INSTAGRAM => 'Automate orders from Instagram',
        ChatPlatform.FACEBOOK => 'Automate orders on Messenger',
        ChatPlatform.TIKTOK => 'Automate orders on TikTok',
      };
    }

    return integration.isActive ? 'Active & Connected' : 'Pending Activation';
  }

  bool _isPlatformActive(
    List<CompanyIntegration> integrations,
    ChatPlatform platform,
  ) {
    return integrations.any((e) => e.platform == platform && e.isActive);
  }

  bool _isPlatformPending(
    List<CompanyIntegration> integrations,
    ChatPlatform platform,
  ) {
    return integrations.any((e) => e.platform == platform && !e.isActive);
  }
}

class _PlatformTile extends StatelessWidget {
  const _PlatformTile({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.leading,
    this.isActive = false,
    this.isPending = false,
    this.enabled = true,
  });

  final Widget? leading;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isActive;
  final bool isPending;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BootstrapSpacing.md),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(BootstrapRadii.xl),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: BootstrapSpacing.md,
              vertical: BootstrapSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: LogistixColors.surface,
              borderRadius: BorderRadius.circular(BootstrapRadii.xl),
              border: Border.all(
                color: isActive
                    ? LogistixColors.primary.withValues(alpha: 0.3)
                    : LogistixColors.border,
                width: isActive ? 2 : 1,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: LogistixColors.primary.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(BootstrapRadii.lg),
                  ),
                  child: leading,
                ),
                const SizedBox(width: BootstrapSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: BootstrapSpacing.xxs),
                      Text(
                        subtitle,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: isPending
                              ? LogistixColors.warning
                              : isActive
                              ? LogistixColors.success
                              : LogistixColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  const Icon(Icons.check_circle, color: LogistixColors.success)
                else if (isPending)
                  const Icon(
                    Icons.hourglass_empty,
                    color: LogistixColors.warning,
                  )
                else if (enabled)
                  const Icon(
                    Icons.chevron_right,
                    color: LogistixColors.textSecondary,
                  )
                else
                  const Icon(
                    Icons.lock_outline,
                    color: LogistixColors.textSecondary,
                    size: 18,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
