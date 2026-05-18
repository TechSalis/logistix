import 'dart:io';

import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:rider/src/domain/repositories/rider_repository.dart';
import 'package:rider/src/presentation/cubit/rider_delivery_details_cubit.dart';
import 'package:rider/src/presentation/widgets/proof_of_delivery_dialog.dart';
import 'package:shared/shared.dart';

class RiderDeliveryDetailsPage extends StatelessWidget {
  const RiderDeliveryDetailsPage({
    required this.deliveryId,
    this.initialDelivery,
    super.key,
  });

  final String deliveryId;
  final Delivery? initialDelivery;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return RiderDeliveryDetailsCubit(context.read<RiderRepository>())
          ..loadDelivery(deliveryId, initialDelivery: initialDelivery);
      },
      child: _RiderDeliveryDetailsView(deliveryId),
    );
  }
}

class _RiderDeliveryDetailsView extends StatelessWidget {
  const _RiderDeliveryDetailsView(this.deliveryId);

  final String deliveryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LogistixColors.background,
      body: BlocConsumer<RiderDeliveryDetailsCubit, RiderDeliveryDetailsState>(
        listener: (context, state) {
          if (state is RiderDeliveryDetailsError) {
            context.toast.showToast(state.message, type: ToastType.error);
          }
        },
        builder: (context, state) {
          if (state is RiderDeliveryDetailsInitial) return const SizedBox.shrink();
          if (state is RiderDeliveryDetailsLoading) {
            return const _DeliveryDetailsShimmer();
          }
          if (state is RiderDeliveryDetailsError) {
            return BootstrapErrorView(message: state.message);
          }
          if (state is RiderDeliveryDetailsLoaded) {
            return _DeliveryLoadedContent(delivery: state.delivery);
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar:
          BlocBuilder<RiderDeliveryDetailsCubit, RiderDeliveryDetailsState>(
            builder: (context, state) {
              if (state is RiderDeliveryDetailsLoaded) {
                return _BottomActionCta(delivery: state.delivery);
              }
              return const SizedBox.shrink();
            },
          ),
    );
  }
}

class _DeliveryLoadedContent extends StatelessWidget {
  const _DeliveryLoadedContent({required this.delivery});
  final Delivery delivery;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverAppBar(title: Text('Delivery Details')),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: BootstrapSpacing.lg,
              vertical: BootstrapSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DeliveryHeader(delivery: delivery, dateFormat: dateFormat),
                const SizedBox(height: BootstrapSpacing.xl),
                const _SectionTitle(title: 'Delivery Details'),
                const SizedBox(height: BootstrapSpacing.md),

                // Main Details Card
                Container(
                  decoration: BoxDecoration(
                    color: LogistixColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: LogistixColors.black.withValues(alpha: 0.03),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: LogistixColors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(BootstrapSpacing.md),
                  child: Column(
                    children: [
                      if (delivery.pickupAddress.isNotEmpty) ...[
                        BootstrapInfoTile(
                          icon: LucideIcons.circleDot,
                          iconColor: LogistixColors.primary,
                          title: 'Pickup',
                          value: delivery.pickupAddress,
                          onTap: delivery.hasPickupPosition
                              ? () => LogistixLauncher.openMap(
                                  delivery.pickupLat!,
                                  delivery.pickupLng!,
                                )
                              : null,
                        ),
                        if (delivery.pickupPhone?.isNotEmpty ?? false)
                          Padding(
                            padding: const EdgeInsets.only(left: 32, top: 4),
                            child: BootstrapInfoTile(
                              icon: LucideIcons.phone,
                              iconColor: LogistixColors.primary,
                              title: 'Call Sender',
                              value: delivery.pickupPhone!,
                              onTap: () => LogistixLauncher.callNumber(
                                delivery.pickupPhone!,
                              ),
                            ),
                          ),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: BootstrapSpacing.sm,
                          ),
                          child: Divider(
                            height: 1,
                            color: LogistixColors.background,
                          ),
                        ),
                      ],
                      BootstrapInfoTile(
                        icon: LucideIcons.flag,
                        iconColor: LogistixColors.orange,
                        title: 'Drop-off',
                        value: delivery.dropOffAddress,
                        isBold: true,
                        onTap: delivery.hasDropOffPosition
                            ? () => LogistixLauncher.openMap(
                                delivery.dropOffLat!,
                                delivery.dropOffLng!,
                              )
                            : null,
                      ),
                      if (delivery.description != null &&
                          delivery.description!.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: BootstrapSpacing.sm,
                          ),
                          child: Divider(
                            height: 1,
                            color: LogistixColors.background,
                          ),
                        ),
                        BootstrapInfoTile(
                          icon: LucideIcons.fileText,
                          iconColor: LogistixColors.textTertiary,
                          title: 'Description',
                          value: delivery.description!,
                        ),
                      ],
                    ],
                  ),
                ),

                if (delivery.price != null && delivery.price! > 0) ...[
                  const SizedBox(height: BootstrapSpacing.md),
                  Container(
                    decoration: BoxDecoration(
                      color: delivery.paymentMethod == PaymentMethod.PAY_ON_DELIVERY
                          ? LogistixColors.orange.withValues(alpha: 0.1)
                          : LogistixColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: delivery.paymentMethod == PaymentMethod.PAY_ON_DELIVERY
                            ? LogistixColors.orange.withValues(alpha: 0.2)
                            : LogistixColors.success.withValues(alpha: 0.2),
                      ),
                    ),
                    padding: const EdgeInsets.all(BootstrapSpacing.md),
                    child: Row(
                      children: [
                        Icon(
                          delivery.paymentMethod == PaymentMethod.PAY_ON_DELIVERY
                              ? LucideIcons.banknote
                              : LucideIcons.circleCheck,
                          color: delivery.paymentMethod == PaymentMethod.PAY_ON_DELIVERY
                              ? LogistixColors.orange
                              : LogistixColors.success,
                        ),
                        const SizedBox(width: BootstrapSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                delivery.paymentMethod == PaymentMethod.PAY_ON_DELIVERY
                                    ? 'COLLECT CASH ON DELIVERY'
                                    : 'DELIVERY PREPAID',
                                style: context.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: delivery.paymentMethod == PaymentMethod.PAY_ON_DELIVERY
                                      ? LogistixColors.orange
                                      : LogistixColors.success,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'Amount: ₦${delivery.price!.toStringAsFixed(0)}',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: LogistixColors.text,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (delivery.scheduledAt != null) ...[
                  const SizedBox(height: BootstrapSpacing.md),
                  Container(
                    decoration: BoxDecoration(
                      color: LogistixColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: LogistixColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    padding: const EdgeInsets.all(BootstrapSpacing.md),
                    child: BootstrapInfoTile(
                      icon: LucideIcons.calendar,
                      iconColor: LogistixColors.primary,
                      title: 'Scheduled Delivery',
                      value: delivery.scheduledAt!.toScheduleString(),
                      isBold: true,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DeliveryHeader extends StatelessWidget {
  const _DeliveryHeader({required this.delivery, required this.dateFormat});

  final Delivery delivery;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '#${delivery.trackingNumber}',
                maxLines: 1,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: LogistixColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    LucideIcons.clock,
                    size: 14,
                    color: LogistixColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateFormat.format(delivery.createdAt.toLocal()),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: LogistixColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _StatusBadge(status: delivery.status),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w900,
        color: LogistixColors.textTertiary,
        letterSpacing: 1,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final DeliveryStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(BootstrapRadii.md),
        border: Border.all(color: status.color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.label,
        style: context.textTheme.labelMedium?.copyWith(
          color: status.color,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _BottomActionCta extends StatelessWidget {
  const _BottomActionCta({required this.delivery});
  final Delivery delivery;

  Widget unassignButton(BuildContext context) {
    final cubit = context.read<RiderDeliveryDetailsCubit>();
    return AsyncRunnerListener(
      runner: cubit.unassignRunner,
      listener: (context, state) {
        if (state.status.isFailure) {
          final error = state.result?.error;
          context.toast.showToast(
            error?.message ?? 'Failed to unassign delivery',
            type: ToastType.error,
          );
        } else if (state.status.isSuccess) {
          Navigator.of(context).pop();
          context.toast.showToast(
            'Delivery unassigned successfully',
            type: ToastType.success,
          );
        }
      },
      child: AsyncRunnerBuilder(
        runner: cubit.unassignRunner,
        builder: (context, state, _) {
          final isLoading = state.status.isRunning;
          return BootstrapButton(
            onPressed: isLoading
                ? null
                : () {
                    BootstrapDialog.show<bool>(
                      context: context,
                      title: 'Unassign Delivery?',
                      content:
                          'Are you sure you want to return this delivery to the pool? You will no longer be responsible for it.',
                      primaryActionText: 'Unassign',
                      onPrimaryAction: (_) => cubit.unassignRunner(),
                      // isDestructive: true,
                    );
                  },
            foregroundColor: LogistixColors.error,
            backgroundColor: LogistixColors.error,
            isLoading: isLoading,
            icon: LucideIcons.circleX,
            label: 'Unassign',
            type: BootstrapButtonType.outline,
          );
        },
      ),
    );
  }

  Widget startDeliveryButton(BuildContext context) {
    final cubit = context.read<RiderDeliveryDetailsCubit>();
    return AsyncRunnerListener(
      runner: cubit.startDeliveryRunner,
      listener: (context, state) {
        if (state.status.isFailure) {
          final error = state.result?.error;
          context.toast.showToast(
            error?.message ?? 'Failed to start delivery',
            type: ToastType.error,
          );
        } else if (state.status.isSuccess) {
          context.toast.showToast('Delivery started', type: ToastType.success);
        }
      },
      child: AsyncRunnerBuilder(
        runner: cubit.startDeliveryRunner,
        builder: (context, state, _) {
          final isLoading = state.status.isRunning;

          return BootstrapButton(
            onPressed: isLoading ? null : cubit.startDeliveryRunner.call,
            label: isLoading ? 'Starting...' : 'Start Delivery',
            icon: LucideIcons.play,
            isLoading: isLoading,
          );
        },
      ),
    );
  }

  Widget markDeliveredButton(BuildContext context) {
    final cubit = context.read<RiderDeliveryDetailsCubit>();
    return AsyncRunnerListener(
      runner: cubit.markDeliveredRunner,
      listener: (context, state) {
        if (state.status.isFailure) {
          final error = state.result?.error;
          context.toast.showToast(
            error?.message ?? 'Failed to mark delivery as delivered',
            type: ToastType.error,
          );
        } else if (state.status.isSuccess) {
          Navigator.of(context).pop();
          context.toast.showToast(
            'Delivery delivered! Great job.',
            type: ToastType.success,
          );
        }
      },
      child: AsyncRunnerBuilder(
        runner: cubit.markDeliveredRunner,
        builder: (context, state, _) {
          final isLoading = state.status.isRunning;

          return BootstrapButton(
            onPressed: isLoading
                ? null
                : () async {
                    final image =
                        await ProofOfDeliveryDialog.show(context, delivery.id);
                    if (image != null) {
                      await cubit.deliverWithProof(File(image.path));
                    }
                  },
            backgroundColor: LogistixColors.success,
            isLoading: isLoading,
            icon: LucideIcons.circleCheck,
            label: 'Mark Delivered',
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget? actionButton;
    switch (delivery.status) {
      case DeliveryStatus.PENDING:
      case DeliveryStatus.ASSIGNED:
        actionButton = startDeliveryButton(context);
      case DeliveryStatus.EN_ROUTE:
        actionButton = Row(
          children: [
            Expanded(flex: 3, child: unassignButton(context)),
            const SizedBox(width: 12),
            Expanded(flex: 4, child: markDeliveredButton(context)),
          ],
        );
      case DeliveryStatus.DELIVERED:
      case DeliveryStatus.CANCELLED:
        actionButton = null;
    }

    if (actionButton == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BootstrapSpacing.lg,
        vertical: BootstrapSpacing.md,
      ),
      decoration: BoxDecoration(
        color: LogistixColors.white,
        boxShadow: [
          BoxShadow(
            color: LogistixColors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(BootstrapRadii.xl),
          topRight: Radius.circular(BootstrapRadii.xl),
        ),
      ),
      child: actionButton,
    );
  }
}

class _DeliveryDetailsShimmer extends StatelessWidget {
  const _DeliveryDetailsShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              const BootstrapShimmer(
                height: 300,
                width: double.infinity,
                borderRadius: BorderRadius.zero,
              ),
              AppBar(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BootstrapShimmer(width: 120, height: 16),
                        SizedBox(height: 8),
                        BootstrapShimmer(width: 200, height: 32),
                        SizedBox(height: 12),
                        BootstrapShimmer(width: 150, height: 14),
                      ],
                    ),
                    BootstrapShimmer(
                      width: 100,
                      height: 36,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                const BootstrapShimmer(width: 150, height: 20),
                const SizedBox(height: 20),
                BootstrapShimmer(
                  width: double.infinity,
                  height: 100,
                  borderRadius: BorderRadius.circular(24),
                ),
                const SizedBox(height: 16),
                BootstrapShimmer(
                  width: double.infinity,
                  height: 100,
                  borderRadius: BorderRadius.circular(24),
                ),
                const SizedBox(height: 16),
                BootstrapShimmer(
                  width: double.infinity,
                  height: 100,
                  borderRadius: BorderRadius.circular(24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
