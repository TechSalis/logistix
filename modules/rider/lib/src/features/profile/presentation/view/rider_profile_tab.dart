import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rider/src/presentation/bloc/rider_bloc.dart';
import 'package:rider/src/presentation/bloc/rider_event.dart';
import 'package:rider/src/presentation/bloc/rider_state.dart';
import 'package:rider/src/presentation/router/rider_routes.dart';
import 'package:shared/shared.dart';
import 'package:go_router/go_router.dart';

class RiderProfileTab extends StatelessWidget {
  const RiderProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final riderBloc = context.read<RiderBloc>();
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: AsyncRunnerListener(
          runner: riderBloc.logoutRunner,
          listener: (context, state) {
            if (state.status.isFailure) {
              context.toast.showToast(
                state.result?.error.message ?? 'Logout failed',
                type: ToastType.error,
              );
            }
          },
          child: BlocBuilder<RiderBloc, RiderState>(
            builder: (context, riderState) {
              return riderState.when(
                initial: () => const Center(child: BootstrapInlineLoader()),
                loading: (_) => const Center(child: BootstrapInlineLoader()),
                error: (message) => BootstrapErrorView(
                  message: message,
                  onRetry: () => context.read<RiderBloc>().add(
                        RiderEvent.fetchProfile(),
                      ),
                ),
                loaded: (rider, orders, isOrdersLoading, location) {
                  return SafeArea(child: _buildProfileContent(context, rider));
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, Rider rider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: BootstrapSpacing.lg),
      child: BootstrapEntrance(
        children: [
          const SizedBox(height: BootstrapSpacing.lg),
          _ProfileHeader(rider: rider),
          const SizedBox(height: BootstrapSpacing.lg),
          _SettingsSection(rider: rider),
          const SizedBox(height: BootstrapSpacing.xl),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.rider});
  final Rider rider;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(BootstrapSpacing.xxs),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: LogistixColors.primary.withValues(alpha: 0.1),
              ),
            ),
            child: BootstrapAvatar(
              name: rider.fullName,
              size: 100,
              statusColor: rider.status.color,
              useGradient: true,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rider.fullName,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: rider.status.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: rider.status.color.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              rider.status.name.capitalizeFirst(),
              style: context.textTheme.labelSmall?.copyWith(
                color: rider.status.color,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.rider});
  final Rider rider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BootstrapSettingsCard(
          title: 'SETTINGS',
          children: [
            BootstrapSettingsTile(
              icon: Icons.person_outline_rounded,
              title: 'Account Info',
              onTap: () => context.push(RiderRoutes.account, extra: rider),
            ),
            BootstrapSettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            final appVersion = snapshot.hasData
                ? '${snapshot.data!.version} (${EnvConfig.instance.environment.capitalizeFirst()})'
                : 'Loading...';
            return BootstrapSettingsCard(
              children: [
                BootstrapSettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'App Version',
                  subtitle: appVersion,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        BootstrapSettingsCard(
          children: [
            BootstrapSettingsTile(
              icon: Icons.logout_rounded,
              title: 'Logout',
              titleColor: LogistixColors.error,
              iconColor: LogistixColors.error,
              onTap: () {
                LogoutConfirmationDialog.show(
                  context,
                  onLogout: context.read<RiderBloc>().logoutRunner.call,
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
