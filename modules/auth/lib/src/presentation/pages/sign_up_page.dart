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

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          signUpError: (message) {
            context.toast.showToast(message, type: ToastType.error);
          },
        );
      },
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: LogistixEntrance(
                children: [
                  Hero(
                    tag: 'logo',
                    child: LogistixAssets.images.icon.image(height: 64),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Join Logistix',
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineMedium?.bold,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your account to get started',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: LogistixColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  LogistixTextField(
                    label: 'Full Name',
                    controller: _nameController,
                    icon: Icons.person_outline,
                    textCapitalization: TextCapitalization.words,
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 16),
                  LogistixTextField(
                    label: 'Email',
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: FormBuilderValidators.email(),
                  ),
                  const SizedBox(height: 16),
                  LogistixTextField(
                    label: 'Password',
                    controller: _passwordController,
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(
                        8,
                        errorText: 'Password must be at least 8 characters',
                      ),
                    ]),
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
                  const SizedBox(height: 16),
                  LogistixTextField(
                    label: 'Confirm Password',
                    controller: _confirmPasswordController,
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
                  const SizedBox(height: 32),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state.maybeWhen(
                        signUpLoading: () => true,
                        orElse: () => false,
                      );
                      return LogistixButton(
                        label: 'Create Account',
                        isLoading: isLoading,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                              AuthEvent.signUp(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                                name: _nameController.text.trim(),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: context.textTheme.bodyMedium,
                      ),
                      LogistixButton(
                        label: 'Sign In',
                        onPressed: () => context.go(AuthRoutes.login),
                        type: LogistixButtonType.text,
                      ),
                    ],
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
