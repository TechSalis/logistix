import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:dispatcher/src/features/deliveries/presentation/cubit/delivery_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared/shared.dart';

class DeliveryActionBar extends StatelessWidget {
  const DeliveryActionBar({required this.delivery, super.key});
  final Delivery delivery;

  @override
  Widget build(BuildContext context) {
    Widget? actionButton;
    final isExternalLogistixApp = delivery.companyId == null;

    switch (delivery.status) {
      case DeliveryStatus.PENDING:
        actionButton = isExternalLogistixApp ? _RejectButton() : _CancelButton();
      case DeliveryStatus.ASSIGNED:
      case DeliveryStatus.EN_ROUTE:
        actionButton = Row(
          children: [
            Expanded(flex: 2, child: _CancelButton()),
            const SizedBox(width: BootstrapSpacing.md),
            Expanded(flex: 3, child: _MarkDeliveredButton()),
          ],
        );
      case DeliveryStatus.DELIVERED:
      case DeliveryStatus.CANCELLED:
        actionButton = null;
    }

    if (actionButton == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: BootstrapSpacing.lg, vertical: BootstrapSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 15, offset: const Offset(0, -4)),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(BootstrapRadii.xl)),
      ),
      child: actionButton,
    );
  }
}

class _CancelButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DeliveryDetailsCubit>();
    return AsyncRunnerListener(
      runner: cubit.cancelRunner,
      listener: (context, state) {
        if (state.status.isFailure) {
          context.toast.showToast(state.result?.error.message ?? 'Failed to cancel', type: ToastType.error);
        }
      },
      child: AsyncRunnerBuilder(
        runner: cubit.cancelRunner,
        builder: (context, state, _) => BootstrapButton(
          onPressed: cubit.cancelRunner.call,
          isLoading: state.status.isRunning,
          label: 'Cancel',
          type: BootstrapButtonType.danger,
          icon: LucideIcons.circleX,
        ),
      ),
    );
  }
}

class _MarkDeliveredButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DeliveryDetailsCubit>();
    return AsyncRunnerListener(
      runner: cubit.markDeliveredRunner,
      listener: (context, state) {
        if (state.status.isSuccess) {
          context.toast.showToast('Delivery delivered', type: ToastType.success);
        } else if (state.status.isFailure) {
          context.toast.showToast(state.result?.error.message ?? 'Failed to deliver', type: ToastType.error);
        }
      },
      child: AsyncRunnerBuilder(
        runner: cubit.markDeliveredRunner,
        builder: (context, state, _) => BootstrapButton(
          onPressed: cubit.markDeliveredRunner.call,
          isLoading: state.status.isRunning,
          label: 'Mark Delivered',
          icon: LucideIcons.circleCheck,
        ),
      ),
    );
  }
}

class _RejectButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DeliveryDetailsCubit>();
    return AsyncRunnerListener(
      runner: cubit.rejectRunner,
      listener: (context, state) {
        if (state.status.isFailure) {
          context.toast.showToast(state.result?.error.message ?? 'Failed to reject', type: ToastType.error);
        }
      },
      child: AsyncRunnerBuilder(
        runner: cubit.rejectRunner,
        builder: (context, state, _) => BootstrapButton(
          onPressed: cubit.rejectRunner.call,
          isLoading: state.status.isRunning,
          label: 'Reject Delivery',
          type: BootstrapButtonType.outline,
          icon: LucideIcons.x,
        ),
      ),
    );
  }
}
