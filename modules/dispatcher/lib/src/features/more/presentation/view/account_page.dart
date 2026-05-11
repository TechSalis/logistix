import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:dispatcher/src/features/more/presentation/cubit/more_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({required this.user, super.key});
  final User user;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MoreCubit>();
    final company = user.companyProfile;

    return Scaffold(
      backgroundColor: LogistixColors.background,
      appBar: AppBar(title: const Text('Account & Company'), centerTitle: true),
      body: AsyncRunnerListener(
        runner: cubit.deleteAccountRunner,
        listener: (context, state) {
          if (state.status.isFailure) {
            context.toast.showToast(
              state.result?.error.message ?? 'Account deletion failed',
              type: ToastType.error,
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(BootstrapSpacing.md),
          child: BootstrapEntrance(
            children: [
              BootstrapSettingsCard(
                title: 'DISPATCHER PROFILE',
                children: [
                  BootstrapSettingsTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Full Name',
                    subtitle: user.fullName,
                  ),
                  BootstrapSettingsTile(
                    icon: Icons.alternate_email_rounded,
                    title: 'Email Address',
                    subtitle: user.email,
                  ),
                  BootstrapSettingsTile(
                    icon: Icons.verified_user_outlined,
                    title: 'Permission Level',
                    subtitle: user.role?.name.toUpperCase() ?? 'NONE',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (company != null)
                BootstrapSettingsCard(
                  title: 'COMPANY INFORMATION',
                  children: [
                    BootstrapSettingsTile(
                      icon: Icons.business_outlined,
                      title: 'Company Name',
                      subtitle: company.name,
                    ),
                    BootstrapSettingsTile(
                      icon: Icons.location_on_outlined,
                      title: 'Terminal Address',
                      subtitle: company.address ?? 'Missing Address',
                    ),
                    BootstrapSettingsTile(
                      icon: Icons.terminal_outlined,
                      title: 'Operation Handle',
                      subtitle:
                          '@${company.businessHandle ?? company.id.substring(0, 8)}',
                    ),
                  ],
                ),
              const SizedBox(height: 32),
              BootstrapSettingsCard(
                title: 'ACCOUNT MANAGEMENT',
                children: [
                  BootstrapSettingsTile(
                    icon: Icons.delete_forever_outlined,
                    title: 'Delete My Account',
                    titleColor: LogistixColors.error,
                    iconColor: LogistixColors.error,
                    onTap: () => showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Account?'),
                        content: const Text(
                          'This will permanently delete your account and all associated data. This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              cubit.deleteAccountRunner.call();
                            },
                            child: const Text(
                              'Delete Now',
                              style: TextStyle(color: LogistixColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
