import 'package:auth/src/presentation/bloc/auth_bloc.dart';
import 'package:auth/src/presentation/bloc/auth_event.dart';
import 'package:auth/src/presentation/bloc/auth_state.dart';
import 'package:auth/src/presentation/router/auth_routes.dart';
import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          verifyOtpError: (message) {
            setState(() {
              _isVerifying = false;
            });
            context.toast.showToast(message, type: ToastType.error);
          },
        );
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Verify Account')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(LogistixSpacing.pagePadding),
            child: LogistixEntrance(
              children: [
                const Icon(
                  Icons.mark_email_read_rounded,
                  size: 100,
                  color: LogistixColors.primary,
                ),
                const SizedBox(height: LogistixSpacing.lg),
                Text(
                  'Verify Your Identity',
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineMedium?.bold,
                ),
                const SizedBox(height: LogistixSpacing.sm),
                Text.rich(
                  TextSpan(
                    text: 'We sent a verification code to ',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: LogistixColors.textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: widget.email,
                        style: context.textTheme.bodyMedium?.semiBold.copyWith(
                          color: LogistixColors.text,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: LogistixSpacing.xxl),
                Pinput(
                  autofocus: true,
                  length: 6,
                  onCompleted: _onOtpCompleted,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  defaultPinTheme: PinTheme(
                    width: 50,
                    height: 56,
                    textStyle: context.textTheme.headlineSmall?.bold,
                    decoration: BoxDecoration(
                      color: LogistixColors.surface,
                      borderRadius: BorderRadius.circular(LogistixRadii.md),
                      border: Border.all(color: LogistixColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: LogistixSpacing.xl),
                if (_isVerifying)
                  const Center(child: LogistixInlineLoader(size: 32))
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive code? ",
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: LogistixColors.textSecondary,
                        ),
                      ),
                      LogistixButton(
                        onPressed: _resendOtp,
                        label: 'Resend',
                        type: LogistixButtonType.text,
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
