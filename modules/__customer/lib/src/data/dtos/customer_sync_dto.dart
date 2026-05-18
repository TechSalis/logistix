import 'package:shared/shared.dart';

class CustomerSyncDto {
  const CustomerSyncDto({
    required this.deliveries,
    required this.lastUpdated,
    this.deletedDeliveryIds = const [],
  });

  factory CustomerSyncDto.fromJson(Map<String, dynamic> json) {
    return CustomerSyncDto(
      deliveries: (json['deliveries'] as List<dynamic>?)
              ?.map((e) => DeliveryDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lastUpdated: json['lastUpdated'] as int? ?? 0,
      deletedDeliveryIds: (json['deletedDeliveryIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  final List<DeliveryDto> deliveries;
  final int lastUpdated;
  final List<String> deletedDeliveryIds;

  Map<String, dynamic> toJson() {
    return {
      'deliveries': deliveries.map((e) => e.toJson()).toList(),
      'lastUpdated': lastUpdated,
      'deletedDeliveryIds': deletedDeliveryIds,
    };
  }
}
