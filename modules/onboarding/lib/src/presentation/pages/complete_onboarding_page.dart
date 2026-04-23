import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:onboarding/onboarding.dart';
import 'package:shared/shared.dart';

class CompleteOnboardingPage extends StatefulWidget {
  const CompleteOnboardingPage({super.key});

  @override
  State<CompleteOnboardingPage> createState() => _CompleteOnboardingPageState();
}

class _CompleteOnboardingPageState extends State<CompleteOnboardingPage> {
  @override
  void initState() {
    super.initState();
    context.read<OnboardingBloc>().add(OnboardingEvent.submitOnboarding());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state.status == OnboardingStatus.error) {
          if (state.message != null) {
            context.toast.showToast(state.message!, type: ToastType.error);
          }
          context.pop();
        }
      },
      builder: (context, state) {
        if (state.status == OnboardingStatus.success) {
          return Scaffold(
            body: BootstrapSuccessView(
              title: 'Account Ready!',
              message:
                  'Your profile has been set up successfully. Welcome to ${EnvConfig.instance.brandName}!',
            ),
          );
        }

        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(BootstrapSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: LogistixColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const BootstrapLoadingIndicator(),
                      )
                      .animate()
                      .scale(
                        duration: 600.ms,
                        begin: const Offset(0.8, 0.8),
                        curve: Curves.easeOutBack,
                      )
                      .fade(duration: 400.ms),
                  const SizedBox(height: BootstrapSpacing.xxl),
                  Text(
                    'Completing your account',
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineSmall?.bold.copyWith(
                      color: LogistixColors.text,
                      letterSpacing: -0.5,
                    ),
                  ).animate(delay: 200.ms).fade().slideY(begin: 0.2),
                  const SizedBox(height: BootstrapSpacing.md),
                  Text(
                    'Setting up your dashboard. One moment...',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: LogistixColors.textSecondary,
                    ),
                  ).animate(delay: 400.ms).fade().slideY(begin: 0.2),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
