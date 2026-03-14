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
      description: 'Deliver packages and earn money',
      icon: Icons.motorcycle,
      color: LogistixColors.primary,
    ),
    RoleOption(
      role: UserRole.dispatcher,
      title: 'Dispatcher',
      description: 'Manage deliveries and riders',
      icon: Icons.admin_panel_settings,
      color: LogistixColors.info,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choose Your Role',
                textAlign: TextAlign.center,
                style: context.textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Select how you want to use Logistix',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: LogistixColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),
              Expanded(
                child: ListView.separated(
                  itemCount: _roles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 20),
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
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _selectedRole == null
                    ? null
                    : () {
                        // Navigate to appropriate onboarding flow
                        context.push(switch (_selectedRole!) {
                          UserRole.rider => OnboardingRoutes.riderOnboarding,
                          UserRole.dispatcher =>
                            OnboardingRoutes.dispatcherOnboarding,
                        });
                      },
                child: const Text('Continue'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  LogistixDialog.show<void>(
                    context: context,
                    title: 'Pause Onboarding',
                    content:
                        'You can return anytime to complete your profile setup.'
                        ' Your progress will be saved.',
                    icon: Icons.pause_circle_outline,
                    primaryActionText: 'Continue Later',
                    secondaryActionText: 'Stay Here',
                    onPrimaryAction: () {
                      Navigator.pop(context);
                      context.read<OnboardingBloc>().backToAuthRunner();
                    },
                  );
                },
                child: const Text('Back To Login'),
              ),
            ],
          ),
        ),
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
    return AnimatedContainer(
      duration: LogistixAnimations.normal,
      curve: LogistixAnimations.emphasized,
      decoration: BoxDecoration(
        color: isSelected
            ? roleOption.color.withValues(alpha: 0.1)
            : LogistixColors.surface,
        border: Border.all(
          color: isSelected ? roleOption.color : LogistixColors.border,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: LogistixRadii.borderRadiusCard,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: LogistixRadii.borderRadiusCard,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: roleOption.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(LogistixRadii.lg),
                ),
                child: Icon(roleOption.icon, size: 32, color: roleOption.color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roleOption.title,
                      style: context.textTheme.titleLarge?.semiBold.copyWith(
                        color: isSelected
                            ? roleOption.color
                            : LogistixColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      roleOption.description,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: LogistixColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
