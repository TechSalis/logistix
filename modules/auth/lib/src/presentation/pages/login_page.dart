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
import 'package:shared/shared.dart';

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
          pendingOnboarding: (_) => context.go(ModuleRoutePaths.onboarding),
          unauthenticated: (message) {
            if (message != null) {
              context.toast.showToast(message, type: ToastType.error);
            }
          },
          authenticated: (user) {
            switch (user.role) {
              case UserRole.rider:
                context.go(ModuleRoutePaths.rider);
              case UserRole.dispatcher:
                context.go(ModuleRoutePaths.dispatcher);
              case null:
                return;
            }
          },
        );
      },
      child: Scaffold(
        body: Align(
          alignment: const Alignment(0, -.5),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              clipBehavior: Clip.none,
              padding: const EdgeInsets.all(32),
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
                TextFormField(
                  autocorrect: false,
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: FormBuilderValidators.email(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
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
                  obscureText: _obscurePassword,
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push(AuthRoutes.forgotPassword),
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 16),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state.maybeWhen(
                      loading: () => true,
                      orElse: () => false,
                    );

                    return ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_formKey.currentState?.validate() ?? true) {
                                context.read<AuthBloc>().add(
                                  AuthEvent.login(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  ),
                                );
                              }
                            },
                      child: isLoading
                          ? const LogistixInlineLoader()
                          : const Text('Login'),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: context.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.go(AuthRoutes.signUp),
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
