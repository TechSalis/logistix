import 'package:shared/shared.dart';

class CustomerSyncDto {
  const CustomerSyncDto({
    required this.orders,
    required this.lastUpdated,
    this.deletedOrderIds = const [],
  });

  factory CustomerSyncDto.fromJson(Map<String, dynamic> json) {
    return CustomerSyncDto(
      orders: (json['orders'] as List<dynamic>?)
              ?.map((e) => OrderDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lastUpdated: json['lastUpdated'] as int? ?? 0,
      deletedOrderIds: (json['deletedOrderIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  final List<OrderDto> orders;
  final int lastUpdated;
  final List<String> deletedOrderIds;

  Map<String, dynamic> toJson() {
    return {
      'orders': orders.map((e) => e.toJson()).toList(),
      'lastUpdated': lastUpdated,
      'deletedOrderIds': deletedOrderIds,
    };
  }
}
