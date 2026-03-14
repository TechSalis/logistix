import 'package:auth/src/presentation/bloc/auth_bloc.dart';
import 'package:auth/src/presentation/bloc/auth_event.dart';
import 'package:auth/src/presentation/bloc/auth_state.dart';
import 'package:auth/src/presentation/router/auth_routes.dart';
import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:pinput/pinput.dart';

class VerifyOtpPage extends StatefulWidget {
  const VerifyOtpPage({required this.email, super.key});

  final String email;

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  bool _isVerifying = false;

  void _onOtpCompleted(String otp) {
    setState(() => _isVerifying = true);

    // Trigger OTP verification
    context.read<AuthBloc>().add(
      AuthEvent.verifyOtp(email: widget.email, otp: otp),
    );
  }

  void _resendOtp() {
    context.read<AuthBloc>().add(AuthEvent.forgotPassword(email: widget.email));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          otpVerified: (email) {
            context.toast.showToast(
              'OTP verified successfully',
              type: ToastType.success,
            );
            context.go('${AuthRoutes.resetPassword}?email=$email');
          },
          unauthenticated: (message) {
            setState(() {
              _isVerifying = false;
            });
            if (message != null) {
              context.toast.showToast(message, type: ToastType.error);
            }
          },
          otpSent: (_) {
            // Handle resend OTP success
          },
        );
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Verify OTP')),
        body: Align(
          alignment: const Alignment(0, -.5),
          child: ListView(
            shrinkWrap: true,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.all(32),
            children: [
              Icon(
                Icons.lock_clock,
                size: 100,
                color: context.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Enter Verification Code',
                textAlign: TextAlign.center,
                style: context.textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text.rich(
                TextSpan(
                  text:
                      'If an account exists for this email, you should receive a 6-digit code to ',
                  children: [
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: LogistixColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),
              Pinput(
                autofocus: true,
                length: 6,
                onCompleted: _onOtpCompleted,
                // defaultPinTheme: pinTheme,
                // focusedPinTheme: pinTheme.copyDecorationWith(
                //   border: Border.all(color: context.colorScheme.primary),
                //   borderRadius: kBorderRadiusDefault,
                // ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: FormBuilderValidators.minLength(6, errorText: ''),
              ),
              const SizedBox(height: 32),
              if (_isVerifying)
                const Center(child: LogistixLoadingIndicator())
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code? ",
                      style: context.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: _resendOtp,
                      child: const Text('Resend'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
