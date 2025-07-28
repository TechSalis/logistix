import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix/core/constants/objects.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';

Future<void> showOrderSummarySheet(BuildContext context, Order order) async {
  await showModalBottomSheet(
    context: context,
    enableDrag: false,
    showDragHandle: true,
    isScrollControlled: true,
    isDismissible: false,
    builder: (context) => _SummaryDialog(order: order),
  );
}

class _SummaryDialog extends StatelessWidget {
  const _SummaryDialog({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding_24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 56),
          const SizedBox(height: 16),
          Text(
            'Order Placed!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Here’s a quick summary of your order:',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          _premiumRow(
            Icons.receipt_long,
            'Reference Number #',
            '#${order.refNumber}',
          ),
          if (order.pickup != null)
            _premiumRow(
              Icons.store_mall_directory,
              'Pickup',
              order.pickup!.name,
            ),
          if (order.dropoff != null)
            _premiumRow(Icons.location_on, 'Dropoff', order.dropoff!.name),
          if (order.price != null)
            _premiumRow(
              Icons.attach_money,
              'Price',
              currencyFormatter.format(order.price),
            ),
          if (order.description.trim().isNotEmpty)
            _premiumRow(Icons.notes, 'Description', order.description),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.pop(true);
                context.pop(true);
              },
              child: const Text('Continue'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

Widget _premiumRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    ),
  );
}
