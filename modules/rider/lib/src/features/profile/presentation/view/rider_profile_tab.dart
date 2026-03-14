import 'package:bootstrap/extensions/string_extension.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rider/src/presentation/bloc/rider_bloc.dart';
import 'package:shared/shared.dart';

class RiderProfileTab extends StatelessWidget {
  const RiderProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final logoutEvent = context.read<RiderBloc>().logoutEvent;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: AsyncRunnerListener(
        runner: logoutEvent,
        listener: (context, state) {
          if (state.status.isSuccess) {
            context.go(ModuleRoutePaths.auth);
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: LogistixColors.primary,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Rider Profile',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 32),
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Account Info'),
              trailing: Icon(Icons.chevron_right),
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.notifications_outlined),
              title: Text('Notifications'),
              trailing: Icon(Icons.chevron_right),
            ),
            const Divider(),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final appVersion = snapshot.hasData
                    ? '${snapshot.data!.version} '
                          '(${EnvConfig.environment.capitalizeFirst()})'
                    : 'Loading...';

                return ListTile(
                  leading: const Icon(
                    Icons.info_outline,
                    color: LogistixColors.primary,
                  ),
                  title: const Text('App version'),
                  subtitle: Text(appVersion),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: LogistixColors.error),
              title: Text(
                'Logout',
                style: context.textTheme.labelLarge?.copyWith(
                  color: LogistixColors.error,
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
          ],
        ),
      ),
    );
  }
}
