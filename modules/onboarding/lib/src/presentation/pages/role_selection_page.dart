import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    return Scaffold(
      backgroundColor: LogistixColors.background,
      body: Stack(
        children: [
          // Decorative background element
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: LogistixDecorations.circleMotif(),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: LogistixSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: LogistixSpacing.xl,
                  ),
                  child: Column(
                    children: [
                      Container(
                            padding: const EdgeInsets.all(LogistixSpacing.md),
                            decoration: BoxDecoration(
                              color: LogistixColors.primary.withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_pin_rounded,
                              size: 48,
                              color: LogistixColors.primary,
                            ),
                          )
                          .animate()
                          .fade(duration: 400.ms)
                          .scale(
                            begin: const Offset(0.85, 0.85),
                            curve: Curves.easeOutBack,
                          ),
                      const SizedBox(height: LogistixSpacing.lg),
                      Text(
                        'Confirm Your Role',
                        textAlign: TextAlign.center,
                        style: context.textTheme.headlineMedium?.bold.copyWith(
                          color: LogistixColors.text,
                        ),
                      ).animate(delay: 80.ms).fade().slideY(begin: 0.15),
                      const SizedBox(height: LogistixSpacing.sm),
                      Text(
                        'Select the role that matches your workflow to get started.',
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: LogistixColors.textSecondary,
                        ),
                      ).animate(delay: 120.ms).fade().slideY(begin: 0.15),
                    ],
                  ),
                ),
                const SizedBox(height: LogistixSpacing.xxl),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: LogistixSpacing.lg,
                    ),
                    itemCount: _roles.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: LogistixSpacing.md),
                    itemBuilder: (context, index) {
                      final roleOption = _roles[index];
                      final isSelected = _selectedRole == roleOption.role;

                      return _RoleCard(
                        roleOption: roleOption,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() => _selectedRole = roleOption.role);
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(LogistixSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LogistixButton(
                        label: 'CONTINUE',
                        onPressed: _selectedRole == null
                            ? null
                            : () {
                                switch (_selectedRole!) {
                                  case UserRole.rider:
                                    context.push(
                                      OnboardingRoutes.riderOnboarding,
                                    );
                                  case UserRole.dispatcher:
                                    context.push(
                                      OnboardingRoutes.dispatcherOnboarding,
                                    );
                                  case UserRole.customer:
                                    return;
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
                ),
              ],
            ),
          ),
        ],
      ),
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
