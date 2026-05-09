import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:dispatcher/src/core/extensions/chat_platform_extension.dart';
import 'package:dispatcher/src/features/more/presentation/cubit/more_cubit.dart';
import 'package:dispatcher/src/features/more/presentation/widgets/platform_picker_sheet.dart';
import 'package:dispatcher/src/features/more/presentation/widgets/platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class RequestIntegrationPage extends StatefulWidget {
  final bool autoOpenPicker;
  const RequestIntegrationPage({super.key, this.autoOpenPicker = false});

  @override
  State<RequestIntegrationPage> createState() => _RequestIntegrationPageState();
}

class _RequestIntegrationPageState extends State<RequestIntegrationPage> {
  @override
  void initState() {
    super.initState();
    if (widget.autoOpenPicker) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final state = context.read<MoreCubit>().state;
          _showPickerSheet(context, state);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MoreCubit, MoreState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: LogistixColors.background,
          appBar: AppBar(title: const Text('AI Automation')),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: LogistixColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_outlined,
                    size: 64,
                    color: LogistixColors.primary,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Automate Your Logistics with AI',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Link your social media and messaging platforms. Our intelligent AI dispatcher will answer customer inquiries, accept orders, and manage dispatching seamlessly—24/7.',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: LogistixColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildFeatureRow(context, Icons.speed, 'Instant responses to clients'),
                const SizedBox(height: 16),
                _buildFeatureRow(context, Icons.support_agent, 'Automated order booking'),
                const SizedBox(height: 16),
                _buildFeatureRow(context, Icons.insights, 'Unified customer database'),
                const Spacer(),
                SafeArea(
                  minimum: const EdgeInsets.only(bottom: 24),
                  child: BootstrapButton(
                    label: 'Request Integration',
                    icon: Icons.add_link_rounded,
                    onPressed: () => _showPickerSheet(context, state),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: LogistixColors.primary, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _showPickerSheet(BuildContext context, MoreState state) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: LogistixColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: LogistixColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              PlatformPickerSheet(
                state: state,
                onPlatformSelected: (platform) {
                  Navigator.pop(bottomSheetContext);
                  _onPlatformSelected(context, state, platform);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onPlatformSelected(
    BuildContext context, 
    MoreState state, 
    ChatPlatform platform,
  ) {
    final moreCubit = context.read<MoreCubit>();
    final toastService = ToastServiceProvider.of(context);

    if (platform == ChatPlatform.WHATSAPP) {
      PlatformActivationForm.show(
        context,
        platform: platform,
        runner: moreCubit.requestIntegrationRunner,
        toastService: toastService,
        user: state is MoreLoaded ? state.user : null,
      );
    } else {
      toastService.showToast(
        '${platform.displayName} coming soon', 
        type: ToastType.info,
      );
    }
  }
}
