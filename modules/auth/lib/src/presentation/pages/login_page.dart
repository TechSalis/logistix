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
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared/src/core/config/project_config.dart';

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
      child: LogistixAuthScaffold(
        header: Hero(
          tag: 'logo',
          child: LogistixAssets.images.icon.image(height: 80),
        ),
        title: ProjectConfig.brandName,
        subtitle: 'Precision in every step',
        footer: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state.maybeWhen(
              loginLoading: () => true,
              orElse: () => false,
            );
            return BootstrapButton(
              label: 'Login',
              isLoading: isLoading,
              onPressed: () {
                if (_formKey.currentState?.validate() ?? true) {
                  context.read<AuthBloc>().add(
                        AuthLogin(
                          email: _emailController.text,
                          password: _passwordController.text,
                        ),
                      );
                }
              },
            );
          },
        ),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                BootstrapTextField(
                  label: 'Email',
                  controller: _emailController,
                  icon: LucideIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  validator: FormBuilderValidators.email(),
                ),
                const SizedBox(height: BootstrapSpacing.md),
                BootstrapTextField(
                  label: 'Password',
                  controller: _passwordController,
                  icon: LucideIcons.lock,
                  obscureText: _obscurePassword,
                  validator: FormBuilderValidators.required(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? LucideIcons.eye
                          : LucideIcons.eyeOff,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                const SizedBox(height: BootstrapSpacing.xs),
                Align(
                  alignment: Alignment.centerRight,
                  child: BootstrapButton(
                    label: 'Forgot Password?',
                    onPressed: () => context.push(AuthRoutes.forgotPassword),
                    type: BootstrapButtonType.text,
                  ),
                ),
                const SizedBox(height: BootstrapSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: context.textTheme.bodyMedium,
                    ),
                    BootstrapButton(
                      label: 'Sign Up',
                      onPressed: () => context.go(AuthRoutes.signUp),
                      type: BootstrapButtonType.text,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
