import 'package:dispatcher/src/domain/usecases/search_riders_usecase.dart';
import 'package:dispatcher/src/features/deliveries/domain/repositories/delivery_repository.dart';
import 'package:dispatcher/src/features/deliveries/presentation/cubit/delivery_details_cubit.dart';
import 'package:dispatcher/src/features/deliveries/presentation/widgets/delivery_action_bar.dart';
import 'package:dispatcher/src/features/deliveries/presentation/widgets/delivery_address_section.dart';
import 'package:dispatcher/src/features/deliveries/presentation/widgets/delivery_map_header.dart';
import 'package:dispatcher/src/features/riders/presentation/widgets/rider_dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared/shared.dart';

class DeliveryDetailsPage extends StatelessWidget {
  const DeliveryDetailsPage({required this.deliveryId, super.key});

  final String deliveryId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeliveryDetailsCubit(context.read<DeliveryRepository>())..loadDelivery(deliveryId),
      child: _DeliveryDetailsView(deliveryId),
    );
  }
}

class _DeliveryDetailsView extends StatelessWidget {
  const _DeliveryDetailsView(this.deliveryId);
  final String deliveryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DeliveryDetailsCubit, DeliveryDetailsState>(
        builder: (context, state) {
          if (state is DeliveryDetailsInitial) return const SizedBox.shrink();
          if (state is DeliveryDetailsLoading) return const _DeliveryDetailsShimmer();
          if (state is DeliveryDetailsError) return BootstrapErrorView(message: state.message);
          if (state is DeliveryDetailsLoaded) return _DeliveryLoadedContent(delivery: state.delivery);
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: BlocBuilder<DeliveryDetailsCubit, DeliveryDetailsState>(
        builder: (context, state) {
          if (state is DeliveryDetailsLoaded) return DeliveryActionBar(delivery: state.delivery);
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
      slivers: [
        DeliveryMapHeader(delivery: delivery),
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

                // Premium details card
                Container(
                  decoration: LogistixDecorations.card(
                    borderColor: LogistixColors.black.withValues(alpha: 0.03),
                  ),
                  padding: const EdgeInsets.all(BootstrapSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DeliveryAddressSection(delivery: delivery),
                      
                      if (delivery.description?.isNotEmpty ?? false) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: BootstrapSpacing.sm),
                          child: Divider(height: 1, color: LogistixColors.background),
                        ),
                        BootstrapInfoTile(
                          icon: LucideIcons.fileText,
                          iconColor: LogistixColors.textTertiary,
                          title: 'Description',
                          value: delivery.description!,
                          isDimmed: true,
                        ),
                      ],
                    ],
                  ),
                ),
                
                if (delivery.scheduledAt != null) ...[
                  const SizedBox(height: BootstrapSpacing.md),
                  Container(
                    decoration: BoxDecoration(
                      color: LogistixColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: LogistixColors.primary.withValues(alpha: 0.1)),
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
                
                const SizedBox(height: BootstrapSpacing.xl),
                _PaymentSection(delivery: delivery),
                const SizedBox(height: BootstrapSpacing.xl),
                _RiderSection(delivery: delivery),
                const SizedBox(height: BootstrapSpacing.xl),
                
                Builder(
                  builder: (context) {
                    final user = context.read<UserStore>().user;
                    final tier = user?.companyProfile?.config?.tier ?? SubscriptionTier.free;
                    final canShare = delivery.canShare(tier);

                    return Center(
                      child: BootstrapButton(
                        onPressed: canShare 
                            ? () => context.read<DeliveryDetailsCubit>().shareDelivery(delivery)
                            : null,
                        label: canShare ? 'Share Tracking Link' : 'Upgrade to Share Link',
                        icon: canShare ? LucideIcons.share2 : LucideIcons.lock,
                        type: BootstrapButtonType.outline,
                        width: 280,
                      ),
                    );
                  }
                ),
                const SizedBox(height: BootstrapSpacing.xl),
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
                'Delivery Overview',
                style: context.textTheme.labelSmall?.copyWith(
                  color: LogistixColors.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '#${delivery.trackingNumber}',
                    style: context.textTheme.headlineMedium?.bold,
                  ),
                  if (delivery.companyId == null) ...[
                    const SizedBox(width: 8),
                    const _ExternalAppBadge(),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              _CreatedAtRow(date: delivery.createdAt),
            ],
          ),
        ),
        _StatusBadge(status: delivery.status),
      ],
    );
  }
}

class _CreatedAtRow extends StatelessWidget {
  const _CreatedAtRow({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(LucideIcons.clock, size: 14, color: LogistixColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          DateFormat('MMM dd, yyyy • hh:mm a').format(date.toLocal()),
          style: context.textTheme.bodySmall?.copyWith(color: LogistixColors.textSecondary),
        ),
      ],
    );
  }
}

class _ExternalAppBadge extends StatelessWidget {
  const _ExternalAppBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: LogistixColors.secondary, borderRadius: BorderRadius.circular(BootstrapRadii.xs)),
      child: Text('APP', style: context.textTheme.labelSmall?.bold.copyWith(color: LogistixColors.white)),
    );
  }
}

class _RiderSection extends StatelessWidget {
  const _RiderSection({required this.delivery});
  final Delivery delivery;

  @override
  Widget build(BuildContext context) {
    if (delivery.rider == null && delivery.status.isCompleted) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rider Assignment',
          style: context.textTheme.labelMedium?.bold.copyWith(color: LogistixColors.textTertiary, letterSpacing: 1),
        ),
        const SizedBox(height: BootstrapSpacing.md),
        AssignRiderDropdownSearch(
          selectedRider: delivery.rider,
          searchRiders: (filter) => context.read<SearchRidersUseCase>().call(
            filter,
            lat: delivery.dropOffLat ?? delivery.pickupLat,
            lng: delivery.dropOffLng ?? delivery.pickupLng,
          ),
          onChanged: (rider) {
            if (rider != null) context.read<DeliveryDetailsCubit>().assignRunner(rider);
          },
          onUnassign: () => context.read<DeliveryDetailsCubit>().unassignRunner(),
          isCompleted: delivery.status.isCompleted,
        ),
      ],
    );
  }
}

class _PaymentSection extends StatelessWidget {
  const _PaymentSection({required this.delivery});
  final Delivery delivery;

  @override
  Widget build(BuildContext context) {
    final hasPrice = delivery.price != null && delivery.price! > 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Details',
          style: context.textTheme.labelMedium?.bold.copyWith(color: LogistixColors.textTertiary, letterSpacing: 1),
        ),
        const SizedBox(height: BootstrapSpacing.md),
        Container(
          decoration: LogistixDecorations.card(
            borderColor: LogistixColors.black.withValues(alpha: 0.03),
          ),
          padding: const EdgeInsets.all(BootstrapSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: BootstrapInfoTile(
                  icon: delivery.paymentMethod == PaymentMethod.PREPAID ? LucideIcons.creditCard : LucideIcons.banknote,
                  title: 'Method',
                  value: delivery.paymentMethod?.label ?? 'Not specified',
                ),
              ),
              if (hasPrice) ...[
                Container(
                  width: 1,
                  height: 30,
                  color: LogistixColors.background,
                  margin: const EdgeInsets.symmetric(horizontal: BootstrapSpacing.md),
                ),
                Expanded(
                  child: BootstrapInfoTile(
                    icon: LucideIcons.coins,
                    iconColor: LogistixColors.primary,
                    title: 'Amount',
                    value: '₦${delivery.price!.toStringAsFixed(0)}',
                    isBold: true,
                  ),
                ),
              ],
            ],
          ),
        ),
       
      ],
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
        style: context.textTheme.labelMedium?.bold.copyWith(color: status.color, letterSpacing: 0.5),
      ),
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
          const BootstrapShimmer(height: 300, width: double.infinity, borderRadius: BorderRadius.zero),
          Padding(
            padding: const EdgeInsets.all(BootstrapSpacing.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BootstrapShimmer(width: double.infinity, height: 80),
                const SizedBox(height: 40),
                const BootstrapShimmer(width: 150, height: 20),
                const SizedBox(height: 20),
                for (var i = 0; i < 3; i++) ...[
                  BootstrapShimmer(width: double.infinity, height: 100, borderRadius: BorderRadius.circular(BootstrapRadii.xxl)),
                  const SizedBox(height: BootstrapSpacing.md),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
