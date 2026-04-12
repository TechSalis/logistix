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
      AuthVerifyOtp(email: widget.email, otp: otp),
    );
  }

  void _resendOtp() {
    context.read<AuthBloc>().add(AuthForgotPassword(email: widget.email));
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
            setState(() => _isVerifying = false);
            context.toast.showToast(message, type: ToastType.error);
          },
        );
      },
      child: LogistixAuthScaffold(
        onBack: () => context.pop(),
        header: Container(
          padding: const EdgeInsets.all(BootstrapSpacing.lg),
          decoration: BoxDecoration(
            color: LogistixColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            size: 40,
            color: LogistixColors.primary,
          ),
        ),
        title: 'Verify Your Identity',
        subtitle: 'We sent a verification code to ${widget.email}',
        footer: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive code? ",
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: LogistixColors.textSecondary,
                  ),
                ),
                BootstrapButton(
                  onPressed: _resendOtp,
                  label: 'Resend',
                  type: BootstrapButtonType.text,
                ),
              ],
            ),
          ],
        ),
        children: [
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(BootstrapRadii.md),
                border: Border.all(color: LogistixColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          if (_isVerifying) ...[
            const SizedBox(height: BootstrapSpacing.xl),
            const Center(child: BootstrapInlineLoader(size: 32)),
          ],
        ],
      ),
    );
  }
}
