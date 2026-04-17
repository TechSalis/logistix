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

class RequestIntegrationPage extends StatelessWidget {
  const RequestIntegrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MoreCubit, MoreState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
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
                    onPlatformSelected: (platform) => 
                        _onPlatformSelected(context, state, platform),
                  ),
                ],
              ),
            ),
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
      // Close the picker page
      Navigator.pop(context);
      
      // Open the activation form (this one can stay as a modal or be another route)
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
