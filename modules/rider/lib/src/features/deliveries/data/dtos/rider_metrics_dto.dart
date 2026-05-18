class RiderMetricsDto {
  const RiderMetricsDto({
    required this.totalDeliveries,
    required this.pendingDeliveries,
    required this.deliveredDeliveries,
  });

  factory RiderMetricsDto.fromJson(Map<String, dynamic> json) {
    return RiderMetricsDto(
      totalDeliveries: json['totalDeliveries'] as int? ?? 0,
      pendingDeliveries: json['pendingDeliveries'] as int? ?? 0,
      deliveredDeliveries: json['deliveredDeliveries'] as int? ?? 0,
    );
  }

  final int totalDeliveries;
  final int pendingDeliveries;
  final int deliveredDeliveries;

  Map<String, dynamic> toJson() {
    return {
      'totalDeliveries': totalDeliveries,
      'pendingDeliveries': pendingDeliveries,
      'deliveredDeliveries': deliveredDeliveries,
    };
  }

  static Map<String, dynamic>? toJsonFunc(RiderMetricsDto? object) {
    return object?.toJson();
  }
}
