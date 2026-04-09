import 'package:auth/src/presentation/bloc/auth_bloc.dart';
import 'package:auth/src/presentation/bloc/auth_event.dart';
import 'package:auth/src/presentation/bloc/auth_state.dart';
import 'package:auth/src/presentation/router/auth_routes.dart';
import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          otpSent: (email) {
            context.push('${AuthRoutes.verifyOtp}?email=$email');
          },
          forgotPasswordError: (message) {
            context.toast.showToast(message, type: ToastType.error);
          },
        );
      },
      child: LogistixAuthScaffold(
        onBack: () => context.pop(),
        header: Container(
          padding: const EdgeInsets.all(LogistixSpacing.lg),
          decoration: BoxDecoration(
            color: LogistixColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            size: 40,
            color: LogistixColors.primary,
          ),
        ),
        title: 'Forgot Password?',
        subtitle: "Enter your email address and we'll send you a one-time password (OTP) to reset your password.",
        footer: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state.maybeWhen(
              forgotPasswordLoading: () => true,
              orElse: () => false,
            );

            return LogistixButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  context.read<AuthBloc>().add(
                        AuthEvent.forgotPassword(
                          email: _emailController.text.trim(),
                        ),
                      );
                }
              },
              isLoading: isLoading,
              label: 'Send OTP',
            );
          },
        ),
        children: [
          Form(
            key: _formKey,
            child: LogistixTextField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              validator: FormBuilderValidators.email(),
            ),
          ),
        ],
      ),
    );
  }
}
