import 'package:customer/src/domain/entities/customer_order_type.dart';
import 'package:customer/src/features/dashboard/presentation/cubit/order_history_cubit.dart';
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
    context.read<OrderHistoryCubit>().refresh();
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
        onRefresh: () => context.read<OrderHistoryCubit>().refresh(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(LogistixSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select a category for your order',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: LogistixColors.textSecondary,
                ),
              ),
              const SizedBox(height: LogistixSpacing.xl),
              _CategoryGrid(),
              const SizedBox(height: LogistixSpacing.xxl),
              _ActiveOrdersSection(),
              const SizedBox(height: LogistixSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveOrdersSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Active Orders', style: context.textTheme.titleMedium?.bold),
            LogistixButton(
              onPressed: () => context.push(CustomerRoutes.history),
              label: 'See All',
              type: LogistixButtonType.text,
            ),
          ],
        ),
        const SizedBox(height: LogistixSpacing.md),
        BlocBuilder<OrderHistoryCubit, OrderHistoryState>(
          builder: (context, state) {
            final activeOrders = state.orders
                .where((o) => !o.status.isCompleted)
                .toList();

            if (state.isLoading && activeOrders.isEmpty) {
              return const Center(child: LogistixLoadingIndicator());
            }

            if (activeOrders.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(LogistixSpacing.xxl),
                decoration: BoxDecoration(
                  color: LogistixColors.background,
                  borderRadius: BorderRadius.circular(LogistixRadii.xl),
                  border: Border.all(color: LogistixColors.border),
                ),
                child: Center(
                  child: Text(
                    'No active orders. Select a category above to start!',
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
              itemCount: activeOrders.length,
              itemBuilder: (context, index) {
                final order = activeOrders[index];
                return OrderPreviewCard(
                  order: order,
                  onTap: () => context.push(
                    CustomerRoutes.orderDetails(order.id),
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
      _Category(CustomerOrderType.foodDelivery, Icons.restaurant_rounded, Colors.orange),
      _Category(CustomerOrderType.pharmacy, Icons.local_pharmacy_rounded, Colors.redAccent),
      _Category(CustomerOrderType.documents, Icons.description_rounded, Colors.blue),
      _Category(CustomerOrderType.groceries, Icons.shopping_cart_rounded, Colors.green),
      _Category(CustomerOrderType.generalErrands, Icons.directions_run_rounded, LogistixColors.primary),
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
            context.push(CustomerRoutes.makeOrder, extra: category.type);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(LogistixRadii.xl),
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

  final CustomerOrderType type;
  final IconData icon;
  final Color color;
}
