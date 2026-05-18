import 'package:customer/src/domain/entities/customer_delivery_type.dart';
import 'package:customer/src/features/dashboard/presentation/cubit/delivery_history_cubit.dart';
import 'package:customer/src/presentation/router/customer_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class CustomerDashboardPage extends StatefulWidget {
  const CustomerDashboardPage({super.key});

  @override
  State<CustomerDashboardPage> createState() => _CustomerDashboardPageState();
}

class _CustomerDashboardPageState extends State<CustomerDashboardPage> {
  @override
  void initState() {
    super.initState();
    // Refresh history to ensure DB is up to date
    context.read<DeliveryHistoryCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LogistixColors.background,
      appBar: AppBar(
        title: Text(
          'What do you need?',
          style: context.textTheme.headlineSmall?.bold,
        ),
        actions: [
          IconButton(
            onPressed: () => context.push(CustomerRoutes.history),
            icon: const Icon(Icons.history_rounded, color: LogistixColors.primary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<DeliveryHistoryCubit>().refresh(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(BootstrapSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select a category for your delivery',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: LogistixColors.textSecondary,
                ),
              ),
              const SizedBox(height: BootstrapSpacing.xl),
              _CategoryGrid(),
              const SizedBox(height: BootstrapSpacing.xxl),
              _ActiveDeliveriesSection(),
              const SizedBox(height: BootstrapSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveDeliveriesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Active Deliveries', style: context.textTheme.titleMedium?.bold),
            BootstrapButton(
              onPressed: () => context.push(CustomerRoutes.history),
              label: 'See All',
              type: BootstrapButtonType.text,
            ),
          ],
        ),
        const SizedBox(height: BootstrapSpacing.md),
        BlocBuilder<DeliveryHistoryCubit, DeliveryHistoryState>(
          builder: (context, state) {
            final activeDeliveries = state.deliveries
                .where((o) => !o.status.isCompleted)
                .toList();

            if (state.isLoading && activeDeliveries.isEmpty) {
              return const Center(child: BootstrapLoadingIndicator());
            }

            if (activeDeliveries.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(BootstrapSpacing.xxl),
                decoration: BoxDecoration(
                  color: LogistixColors.background,
                  borderRadius: BorderRadius.circular(BootstrapRadii.xl),
                  border: Border.all(color: LogistixColors.border),
                ),
                child: Center(
                  child: Text(
                    'No active deliveries. Select a category above to start!',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: LogistixColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeDeliveries.length,
              itemBuilder: (context, index) {
                final delivery = activeDeliveries[index];
                return DeliveryPreviewCard(
                  delivery: delivery,
                  onTap: () => context.push(
                    CustomerRoutes.deliveryDetails(delivery.id),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final categories = [
      _Category(CustomerDeliveryType.foodDelivery, Icons.restaurant_rounded, Colors.orange),
      _Category(CustomerDeliveryType.pharmacy, Icons.local_pharmacy_rounded, Colors.redAccent),
      _Category(CustomerDeliveryType.documents, Icons.description_rounded, Colors.blue),
      _Category(CustomerDeliveryType.groceries, Icons.shopping_cart_rounded, Colors.green),
      _Category(CustomerDeliveryType.generalErrands, Icons.directions_run_rounded, LogistixColors.primary),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return AnimatedScaleTap(
          onTap: () {
            context.push(CustomerRoutes.makeDelivery, extra: category.type);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(BootstrapRadii.xl),
              border: Border.all(color: LogistixColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    category.icon,
                    size: 32,
                    color: category.color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  category.type.title,
                  style: context.textTheme.labelMedium?.bold.copyWith(
                    color: LogistixColors.text,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Category {
  _Category(this.type, this.icon, this.color);

  final CustomerDeliveryType type;
  final IconData icon;
  final Color color;
}
