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
      child: Scaffold(
        appBar: AppBar(title: const Text('Forgot Password')),
        body: Align(
          alignment: const Alignment(0, -.75),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              clipBehavior: Clip.none,
              padding: const EdgeInsets.all(32),
              children: [
                Icon(
                  Icons.lock_reset,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Reset Password',
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  "Enter your email address and we'll send you a one-time password (OTP) to reset your password.",
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: LogistixColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  autocorrect: false,
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  validator: FormBuilderValidators.email(),
                ),
                const SizedBox(height: 32),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state.maybeWhen(
                      forgotPasswordLoading: () => true,
                      orElse: () => false,
                    );

                    return ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_formKey.currentState?.validate() ?? false) {
                                context.read<AuthBloc>().add(
                                  AuthEvent.forgotPassword(
                                    email: _emailController.text.trim(),
                                  ),
                                );
                              }
                            },
                      child: isLoading
                          ? const LogistixInlineLoader()
                          : const Text('Send OTP'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
