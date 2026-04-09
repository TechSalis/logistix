import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:collection/collection.dart';
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
  final void Function(Platform) onPlatformSelected;

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

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: AsyncRunnerBuilder(
        runner: runner,
        builder: (context, runnerState, _) {
          return widget.state.maybeWhen(
            loaded: (_, user) {
              final integrations = user?.companyProfile?.integrations ?? [];
              
              if (runnerState.status.isRunning && integrations.isEmpty) {
                 return const Center(
                   child: Padding(
                     padding: EdgeInsets.symmetric(vertical: 40),
                     child: CircularProgressIndicator(),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Connect Platforms',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      if (runnerState.status.isRunning)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Select a channel to automate your logistics with ',
                        ),
                        TextSpan(
                          text: 'Logistix AI.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    style: TextStyle(color: LogistixColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  if (runnerState.status.isFailure)
                    _buildInlineError(runnerState.result?.error.message ?? 'Refresh failed', runner),
                  _PlatformTile(
                    icon: Icons.message,
                    title: 'WhatsApp Business',
                    subtitle: _getPlatformStatus(integrations, Platform.whatsapp),
                    color: const Color(0xFF25D366),
                    isActive: _isPlatformActive(integrations, Platform.whatsapp),
                    isPending: _isPlatformPending(integrations, Platform.whatsapp),
                    onTap: () => widget.onPlatformSelected(Platform.whatsapp),
                  ),
                  _PlatformTile(
                    icon: Icons.camera_alt_outlined,
                    title: 'Instagram DM',
                    subtitle: _getPlatformStatus(integrations, Platform.instagram),
                    color: const Color(0xFFE4405F),
                    enabled: false,
                    onTap: () => widget.onPlatformSelected(Platform.instagram),
                  ),
                  _PlatformTile(
                    icon: Icons.facebook,
                    title: 'Facebook Messenger',
                    subtitle: _getPlatformStatus(integrations, Platform.facebook),
                    color: const Color(0xFF1877F2),
                    enabled: false,
                    onTap: () => widget.onPlatformSelected(Platform.facebook),
                  ),
                  _PlatformTile(
                    icon: Icons.music_note,
                    title: 'TikTok',
                    subtitle: _getPlatformStatus(integrations, Platform.tiktok),
                    color: Colors.black,
                    enabled: false,
                    onTap: () => widget.onPlatformSelected(Platform.tiktok),
                  ),
                ],
              );
            },
            orElse: () => const SizedBox(),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(AsyncRunner runner) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: LogistixColors.error),
            const SizedBox(height: 16),
            const Text(
              'Failed to load integrations',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LogistixButton(
              label: 'Try Again',
              onPressed: () => runner(),
              type: LogistixButtonType.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineError(String message, AsyncRunner runner) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => runner(),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: LogistixColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.refresh, size: 16, color: LogistixColors.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: LogistixColors.error, fontSize: 13),
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
    Platform platform,
  ) {
    final integration = integrations.firstWhereOrNull(
      (e) => e.platform == platform,
    );

    if (integration == null) {
      return switch (platform) {
        Platform.whatsapp => 'Automate orders from WhatsApp+',
        Platform.instagram => 'Automate orders from Instagram',
        Platform.facebook => 'Automate orders on Messenger',
        Platform.tiktok => 'Automate orders on TikTok',
        _ => 'Automate orders for this platform',
      };
    }

    return integration.isActive ? 'Active & Connected' : 'Pending Activation';
  }

  bool _isPlatformActive(
    List<CompanyIntegration> integrations,
    Platform platform,
  ) {
    return integrations.any((e) => e.platform == platform && e.isActive);
  }

  bool _isPlatformPending(
    List<CompanyIntegration> integrations,
    Platform platform,
  ) {
    return integrations.any((e) => e.platform == platform && !e.isActive);
  }
}
