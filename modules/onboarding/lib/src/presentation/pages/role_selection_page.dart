import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:onboarding/onboarding.dart';
import 'package:shared/shared.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  UserRole? _selectedRole;

  final List<RoleOption> _roles = const [
    RoleOption(
      role: UserRole.rider,
      title: 'Rider',
      description: 'Deliver packages and manage your routes.',
      icon: Icons.motorcycle_rounded,
      color: LogistixColors.primary,
    ),
    RoleOption(
      role: UserRole.dispatcher,
      title: 'Dispatcher',
      description: 'Oversee operations and manage your fleet of riders.',
      icon: Icons.dashboard_customize_rounded,
      color: LogistixColors.info,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LogistixAuthScaffold(
      header: Container(
        padding: const EdgeInsets.all(LogistixSpacing.md),
        decoration: BoxDecoration(
          color: LogistixColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.person_pin_rounded,
          size: 40,
          color: LogistixColors.primary,
        ),
      ),
      title: 'Confirm Your Role',
      subtitle: 'Select the role that matches your workflow to get started.',
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LogistixButton(
            label: 'Continue',
            onPressed: _selectedRole == null
                ? null
                : () {
                    switch (_selectedRole!) {
                      case UserRole.rider:
                        context.push(OnboardingRoutes.riderOnboarding);
                      case UserRole.dispatcher:
                        context.push(OnboardingRoutes.dispatcherOnboarding);
                    }
                  },
          ),
          const SizedBox(height: LogistixSpacing.sm),
          LogistixButton(
            label: 'Back to Login',
            onPressed: context.read<OnboardingBloc>().backToAuth,
            type: LogistixButtonType.text,
          ),
        ],
      ),
      children: [
        ...List.generate(_roles.length, (index) {
          final roleOption = _roles[index];
          final isSelected = _selectedRole == roleOption.role;

          return Padding(
            padding: const EdgeInsets.only(bottom: LogistixSpacing.md),
            child: _RoleCard(
              roleOption: roleOption,
              isSelected: isSelected,
              onTap: () {
                setState(() => _selectedRole = roleOption.role);
              },
            ),
          );
        }),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.roleOption,
    required this.isSelected,
    required this.onTap,
  });

  final RoleOption roleOption;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LogistixCard(
      onTap: onTap,
      borderColor: isSelected ? roleOption.color : LogistixColors.border,
      borderRadius: BorderRadius.circular(24),
      shadowColor: isSelected
          ? roleOption.color.withValues(alpha: 0.15)
          : Colors.black.withValues(alpha: 0.03),
      child: Row(
        children: [
          AnimatedContainer(
            duration: LogistixAnimations.normal,
            padding: const EdgeInsets.all(LogistixSpacing.sm),
            decoration: BoxDecoration(
              color: isSelected
                  ? roleOption.color
                  : roleOption.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              roleOption.icon,
              size: 32,
              color: isSelected ? Colors.white : roleOption.color,
            ),
          ),
          const SizedBox(width: LogistixSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roleOption.title,
                  style: context.textTheme.titleLarge?.bold.copyWith(
                    color: LogistixColors.text,
                  ),
                ),
                const SizedBox(height: LogistixSpacing.xxs),
                Text(
                  roleOption.description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: LogistixColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RoleOption {
  const RoleOption({
    required this.role,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final UserRole role;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
}
