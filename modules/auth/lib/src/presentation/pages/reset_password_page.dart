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

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({required this.email, super.key});

  final String email;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          passwordResetSuccess: () {
            context.toast.showToast(
              'Password reset successful. Please login with your new password.',
              type: ToastType.success,
            );
            context.go(AuthRoutes.login);
          },
          resetPasswordError: (message) {
            context.toast.showToast(message, type: ToastType.error);
          },
        );
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('New Password')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(LogistixSpacing.pagePadding),
            child: Form(
              key: _formKey,
              child: LogistixEntrance(
                children: [
                  const Icon(
                    Icons.vpn_key_rounded,
                    size: 80,
                    color: LogistixColors.primary,
                  ),
                  const SizedBox(height: LogistixSpacing.lg),
                  Text(
                    'Create New Password',
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineMedium?.bold,
                  ),
                  const SizedBox(height: LogistixSpacing.sm),
                  Text(
                    'Secure your account by choosing a strong password for ${widget.email}',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: LogistixColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: LogistixSpacing.xxl),
                  LogistixTextField(
                    controller: _passwordController,
                    label: 'New Password',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    validator: FormBuilderValidators.password(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  const SizedBox(height: LogistixSpacing.md),
                  LogistixTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    icon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: LogistixSpacing.xl),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state.maybeWhen(
                        resetPasswordLoading: () => true,
                        orElse: () => false,
                      );

                      return LogistixButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            context.read<AuthBloc>().add(
                                  AuthEvent.resetPassword(
                                    email: widget.email,
                                    newPassword: _passwordController.text,
                                  ),
                                );
                          }
                        },
                        isLoading: isLoading,
                        label: 'Change Password',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
