import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:rider/src/presentation/bloc/rider_bloc.dart';
import 'package:rider/src/presentation/bloc/rider_event.dart';
import 'package:shared/shared.dart';

class RiderAccountPage extends StatelessWidget {
  const RiderAccountPage({required this.rider, super.key});
  final Rider rider;

  @override
  Widget build(BuildContext context) {
    final riderBloc = context.read<RiderBloc>();

    return Scaffold(
      backgroundColor: LogistixColors.background,
      appBar: AppBar(
        title: const Text('Account Information'),
        centerTitle: true,
      ),
      body: AsyncRunnerListener(
        runner: riderBloc.deleteAccountRunner,
        listener: (context, state) {
          if (state.status.isFailure) {
            context.toast.showToast(
              state.result?.error.message ?? 'Account deletion failed',
              type: ToastType.error,
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(BootstrapSpacing.lg),
          child: BootstrapEntrance(
            children: [
              BootstrapSettingsCard(
                title: 'PERSONAL DETAILS',
                children: [
                  BootstrapSettingsTile(
                    icon: LucideIcons.user,
                    title: 'Full Name',
                    subtitle: rider.fullName,
                  ),
                  BootstrapSettingsTile(
                    icon: LucideIcons.mail,
                    title: 'Email Address',
                    subtitle: rider.email,
                  ),
                  BootstrapSettingsTile(
                    icon: LucideIcons.phone,
                    title: 'Phone Number',
                    subtitle: rider.phoneNumber ?? 'Not provided',
                  ),
                ],
              ),
              const SizedBox(height: BootstrapSpacing.xl),
              BootstrapSettingsCard(
                title: 'ACCOUNT MANAGEMENT',
                children: [
                  BootstrapSettingsTile(
                    icon: LucideIcons.userX,
                    title: 'Delete Account',
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
                              riderBloc.add(RiderEvent.deleteAccount());
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
