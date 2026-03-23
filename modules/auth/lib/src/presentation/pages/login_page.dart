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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          loginError: (message) {
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
                    child: LogistixAssets.images.icon.image(height: 100),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Logistix',
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineLarge?.bold,
                  ),
                  const SizedBox(height: 48),
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
                    validator: FormBuilderValidators.required(),
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
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: LogistixButton(
                      label: 'Forgot Password?',
                      onPressed: () => context.push(AuthRoutes.forgotPassword),
                      type: LogistixButtonType.text,
                    ),
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state.maybeWhen(
                        loginLoading: () => true,
                        orElse: () => false,
                      );
                      return LogistixButton(
                        label: 'Login',
                        isLoading: isLoading,
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? true) {
                            context.read<AuthBloc>().add(
                                  AuthEvent.login(
                                    email: _emailController.text,
                                    password: _passwordController.text,
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
                        "Don't have an account? ",
                        style: context.textTheme.bodyMedium,
                      ),
                      LogistixButton(
                        label: 'Sign Up',
                        onPressed: () => context.go(AuthRoutes.signUp),
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
