import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:onboarding/onboarding.dart';

class CompleteOnboardingPage extends StatefulWidget {
  const CompleteOnboardingPage({super.key});

  @override
  State<CompleteOnboardingPage> createState() => _CompleteOnboardingPageState();
}

class _CompleteOnboardingPageState extends State<CompleteOnboardingPage> {
  @override
  void initState() {
    super.initState();
    context.read<OnboardingBloc>().add(
      const OnboardingEvent.submitOnboarding(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        final status = state.status;
        final message = state.message;

        if (status == OnboardingStatus.error && message != null) {
          context.toast.showToast(message, type: ToastType.error);
        }
      },
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(LogistixSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Premium "Completing Account" Animation
                BlocBuilder<OnboardingBloc, OnboardingState>(
                      builder: (context, state) {
                        final color = state.mapOrNull(
                          dispatcher: (_) => LogistixColors.primary,
                          rider: (_) => LogistixColors.info,
                          customer: (_) => LogistixColors.warning,
                        );

                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: color?.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const LogistixLoadingIndicator(),
                        );
                      },
                    )
                    .animate()
                    .scale(
                      duration: 600.ms,
                      begin: const Offset(0.8, 0.8),
                      curve: Curves.easeOutBack,
                    )
                    .fade(duration: 400.ms),
                const SizedBox(height: LogistixSpacing.xxl),
                Text(
                  'Completing your account',
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineSmall?.bold.copyWith(
                    color: LogistixColors.text,
                    letterSpacing: -0.5,
                  ),
                ).animate(delay: 200.ms).fade().slideY(begin: 0.2),
                const SizedBox(height: LogistixSpacing.md),
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
      ),
    );
  }
}
