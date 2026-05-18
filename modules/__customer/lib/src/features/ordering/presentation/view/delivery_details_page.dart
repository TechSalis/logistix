import 'package:customer/src/domain/repositories/customer_delivery_repository.dart';
import 'package:customer/src/features/ordering/presentation/cubit/delivery_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class DeliveryDetailsPage extends StatelessWidget {
  const DeliveryDetailsPage({required this.deliveryId, super.key});

  final String deliveryId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeliveryDetailsCubit(
        context.read<CustomerDeliveryRepository>(),
        deliveryId,
      ),
      child: const _DeliveryDetailsView(),
    );
  }
}

class _DeliveryDetailsView extends StatelessWidget {
  const _DeliveryDetailsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LogistixColors.background,
      body: BlocBuilder<DeliveryDetailsCubit, DeliveryDetailsState>(
        builder: (context, state) {
          if (state.isLoading && state.delivery == null) {
            return const Center(child: BootstrapLoadingIndicator());
          }

          if (state.error != null && state.delivery == null) {
            return Center(
              child: BootstrapEmptyView(
                title: 'Delivery not found',
                description: state.error,
                icon: Icons.error_outline_rounded,
              ),
            );
          }

          final delivery = state.delivery;
          if (delivery == null) return const SizedBox.shrink();

          return CustomScrollView(
            slivers: [
              _DeliverySliverAppBar(delivery: delivery),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(BootstrapSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DeliveryHeader(delivery: delivery),
                      const SizedBox(height: BootstrapSpacing.xl),
                      _StatusBanner(delivery: delivery),
                      const SizedBox(height: BootstrapSpacing.xl),
                      const _SectionTitle(title: 'Delivery Details'),
                      const SizedBox(height: BootstrapSpacing.sm),
                      _DeliveryLocationInfo(delivery: delivery),
                      const SizedBox(height: BootstrapSpacing.xl),
                      const _SectionTitle(title: 'Description'),
                      const SizedBox(height: BootstrapSpacing.xs),
                      Text(
                        delivery.description ?? 'No extra details provided',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: LogistixColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: BootstrapSpacing.xl),
                      if (delivery.rider != null) ...[
                        const _SectionTitle(title: 'Assigned Rider'),
                        const SizedBox(height: BootstrapSpacing.sm),
                        _RiderCard(rider: delivery.rider!),
                      ],
                      const SizedBox(height: BootstrapSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DeliverySliverAppBar extends StatelessWidget {
  const _DeliverySliverAppBar({required this.delivery});
  final Delivery delivery;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [LogistixColors.primary, LogistixColors.secondaryDark],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeliveryHeader extends StatelessWidget {
  const _DeliveryHeader({required this.delivery});
  final Delivery delivery;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    return Column(
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
        const SizedBox(height: BootstrapSpacing.xxs),
        Text(
          '#${delivery.trackingNumber}',
          style: context.textTheme.headlineSmall?.bold.copyWith(
            color: LogistixColors.text,
          ),
        ),
        const SizedBox(height: BootstrapSpacing.xs),
        Row(
          children: [
            const Icon(Icons.access_time_rounded, size: 14, color: LogistixColors.textTertiary),
            const SizedBox(width: BootstrapSpacing.xs),
            Text(
              dateFormat.format(delivery.createdAt.toLocal()),
              style: context.textTheme.bodySmall?.copyWith(color: LogistixColors.textTertiary),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.delivery});
  final Delivery delivery;

  @override
  Widget build(BuildContext context) {
    final color = delivery.status.color;
    return Container(
      padding: const EdgeInsets.all(BootstrapSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(BootstrapSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(delivery.status.icon, color: color, size: 28),
          ),
          const SizedBox(width: BootstrapSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  delivery.status.label,
                  style: context.textTheme.titleSmall?.bold.copyWith(color: color),
                ),
                const SizedBox(height: BootstrapSpacing.xxs),
                Text(
                  delivery.status.description,
                  style: context.textTheme.bodySmall?.copyWith(color: color.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
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
      style: context.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w900,
        color: LogistixColors.textTertiary,
        letterSpacing: 1,
      ),
    );
  }
}

class _DeliveryLocationInfo extends StatelessWidget {
  const _DeliveryLocationInfo({required this.delivery});
  final Delivery delivery;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (delivery.pickupAddress.isNotEmpty) ...[
          BootstrapInfoTile(
            icon: Icons.trip_origin_rounded,
            iconColor: LogistixColors.primary,
            title: 'Pickup',
            value: delivery.pickupAddress,
            onTap: delivery.hasPickupPosition
                ? () => LogistixLauncher.openMap(delivery.pickupLat!, delivery.pickupLng!)
                : null,
          ),
          const SizedBox(height: BootstrapSpacing.sm),
        ],
        BootstrapInfoTile(
          icon: Icons.flag_rounded,
          iconColor: Colors.orange,
          title: 'Drop-off',
          value: delivery.dropOffAddress,
          isBold: true,
          onTap: delivery.hasDropOffPosition
              ? () => LogistixLauncher.openMap(delivery.dropOffLat!, delivery.dropOffLng!)
              : null,
        ),
      ],
    );
  }
}

class _RiderCard extends StatelessWidget {
  const _RiderCard({required this.rider});
  final Rider rider;

  @override
  Widget build(BuildContext context) {
    return BootstrapCard(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: LogistixColors.primary.withValues(alpha: 0.1),
          child: const Icon(Icons.person_outline_rounded, color: LogistixColors.primary),
        ),
        title: Text(rider.fullName, style: context.textTheme.titleSmall?.bold),
        subtitle: Text(rider.phoneNumber ?? 'No phone'),
        trailing: rider.phoneNumber != null
            ? IconButton(
                icon: const Icon(Icons.call_rounded, color: LogistixColors.success),
                onPressed: () => LogistixLauncher.callNumber(rider.phoneNumber!),
              )
            : null,
      ),
    );
  }
}
