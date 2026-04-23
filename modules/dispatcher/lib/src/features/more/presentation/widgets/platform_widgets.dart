import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:dispatcher/src/features/more/data/dtos/activation_request_dto.dart';
import 'package:dispatcher/src/features/more/presentation/cubit/more_cubit.dart';
import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class PlatformActivationForm extends StatefulWidget {
  const PlatformActivationForm({
    required this.platform,
    required this.onSuccess,
    required this.runner,
    this.user,
    super.key,
  });

  final ChatPlatform platform;
  final User? user;
  final VoidCallback onSuccess;
  final AsyncRunnerWithArg<ActivationRequestDto, AppError, void> runner;

  static Future<void> show(
    BuildContext context, {
    required ChatPlatform platform,
    required AsyncRunnerWithArg<ActivationRequestDto, AppError, void> runner,
    required IToastService toastService,
    User? user,
  }) {
    return BootstrapDialog.show<void>(
      context: context,
      title: 'Activate ${platform.name.toLowerCase().capitalizeFirst()}',
      content: 'Fill in your contact details for activation.',
      icon: Icons.rocket_launch_outlined,
      actionsBuilder: (dialogContext) {
        return [
          ToastServiceProvider(
            service: toastService,
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
  }

  @override
  State<PlatformActivationForm> createState() => _PlatformActivationFormState();
}

class _PlatformActivationFormState extends State<PlatformActivationForm> {
  late final TextEditingController _emailCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  bool _useDedicatedNumber = false;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _nameCtrl = TextEditingController(
      text: user?.companyProfile?.name ?? user?.fullName ?? '',
    );
    _phoneCtrl = TextEditingController(text: user?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final runner = widget.runner;
    final toast = context.toast;

    return AsyncRunnerListener(
      runner: runner,
      listener: (context, state) {
        if (state.status.isSuccess) {
          widget.onSuccess();
          toast.showToast(
            'Request sent! Our team will contact you.',
            type: ToastType.success,
          );
        }
      },
      child: AsyncRunnerBuilder(
        runner: runner,
        builder: (context, runnerState, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BootstrapTextField(
                label: 'Business Name',
                controller: _nameCtrl,
                icon: Icons.business,
              ),
              const SizedBox(height: BootstrapSpacing.md),
              BootstrapTextField(
                label: 'Contact Email',
                controller: _emailCtrl,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: BootstrapSpacing.md),
              BootstrapTextField(
                label: 'Contact Phone',
                controller: _phoneCtrl,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                hintText: '+234...',
              ),
              const SizedBox(height: BootstrapSpacing.md),
              SwitchListTile.adaptive(
                title: Text('Use dedicated number', style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text('Get a fully branded phone number exclusively for your logistics company.', style: context.textTheme.bodySmall),
                value: _useDedicatedNumber,
                onChanged: (val) => setState(() => _useDedicatedNumber = val),
                contentPadding: EdgeInsets.zero,
                activeColor: LogistixColors.primary,
              ),
              const SizedBox(height: BootstrapSpacing.xxl),
              if (runnerState.status.isFailure) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: BootstrapSpacing.md,
                    vertical: BootstrapSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: LogistixColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(BootstrapRadii.md),
                  ),
                  child: Text(
                    runnerState.result?.error.message ?? 'An error occurred',
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: LogistixColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: BootstrapSpacing.lg),
              ],
              BootstrapButton(
                label: 'Request Activation',
                isLoading: runnerState.status.isRunning,
                onPressed: () => runner(
                  ActivationRequestDto(
                    email: _emailCtrl.text,
                    name: _nameCtrl.text,
                    phone: _phoneCtrl.text,
                    platform: widget.platform,
                    useDedicatedNumber: _useDedicatedNumber,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ExportTile extends StatelessWidget {
  const ExportTile({
    required this.runner,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
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
        return BootstrapSettingsTile(
          icon: icon,
          title: title,
          subtitle: subtitle,
          onTap: onTap,
          trailing: isLoading ? const BootstrapInlineLoader() : null,
        );
      },
    );
  }
}
