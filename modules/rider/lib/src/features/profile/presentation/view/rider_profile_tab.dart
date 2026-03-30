import 'package:bootstrap/extensions/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rider/src/presentation/bloc/rider_bloc.dart';
import 'package:rider/src/presentation/bloc/rider_event.dart';
import 'package:rider/src/presentation/bloc/rider_state.dart';
import 'package:shared/shared.dart';

class RiderProfileTab extends StatelessWidget {
  const RiderProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: BlocBuilder<RiderBloc, RiderState>(
          builder: (context, riderState) {
            return riderState.when(
              initial: () => const Center(child: LogistixInlineLoader()),
              loading: (_) => const Center(child: LogistixInlineLoader()),
              error: (message) => LogistixErrorView(
                message: message,
                onRetry: () => context.read<RiderBloc>().add(
                  const RiderEvent.fetchProfile(),
                ),
              ),
              loaded: (rider, orders, isOrdersLoading, location) {
                return SafeArea(child: _buildProfileContent(context, rider));
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, Rider rider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: LogistixSpacing.lg),
      child: LogistixEntrance(
        children: [
          const SizedBox(height: 20),
          _ProfileHeader(rider: rider),
          const SizedBox(height: 24),
          if (rider.activeOrder != null) ...[
            _ActiveOrderCard(order: rider.activeOrder!),
            const SizedBox(height: 24),
          ],
          const _SettingsSection(),
          const SizedBox(height: 32),
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
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: LogistixColors.primary.withValues(alpha: 0.1),
              ),
            ),
            child: LogistixAvatar(
              name: rider.fullName,
              size: 100,
              statusColor: rider.status.color,
              useGradient: true,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rider.fullName,
            style: context.textTheme.headlineSmall?.bold.copyWith(
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

class _ActiveOrderCard extends StatelessWidget {
  const _ActiveOrderCard({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            LogistixColors.primary.withValues(alpha: 0.08),
            LogistixColors.primary.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: LogistixColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: LogistixColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.delivery_dining_rounded,
              color: LogistixColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Order',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: LogistixColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '#${order.trackingNumber}',
                  style: context.textTheme.titleSmall?.bold,
                ),
                if (order.description != null)
                  Text(
                    order.description!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: LogistixColors.textSecondary,
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
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LogistixSettingsCard(
          title: 'SETTINGS',
          children: [
            LogistixSettingsTile(
              icon: Icons.person_outline_rounded,
              title: 'Account Info',
              onTap: () {},
            ),
            LogistixSettingsTile(
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
            return LogistixSettingsCard(
              children: [
                LogistixSettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'App Version',
                  subtitle: appVersion,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        LogistixSettingsCard(
          children: [
            LogistixSettingsTile(
              icon: Icons.logout_rounded,
              title: 'Logout',
              titleColor: LogistixColors.error,
              iconColor: LogistixColors.error,
              onTap: () {
                LogistixDialog.show<void>(
                  context: context,
                  title: 'Logout',
                  content: 'Are you sure you want to sign out?',
                  icon: Icons.logout_rounded,
                  isDestructive: true,
                  primaryActionText: 'Logout',
                  secondaryActionText: 'Cancel',
                  onPrimaryAction: (ctx) {
                    context.read<RiderBloc>().logout();
                    Navigator.pop(ctx);
                  },
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
