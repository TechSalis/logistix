class RiderMetricsDto {
  const RiderMetricsDto({
    required this.totalOrders,
    required this.pendingOrders,
    required this.deliveredOrders,
  });

  factory RiderMetricsDto.fromJson(Map<String, dynamic> json) {
    return RiderMetricsDto(
      totalOrders: json['totalOrders'] as int? ?? 0,
      pendingOrders: json['pendingOrders'] as int? ?? 0,
      deliveredOrders: json['deliveredOrders'] as int? ?? 0,
    );
  }

  final int totalOrders;
  final int pendingOrders;
  final int deliveredOrders;

  Map<String, dynamic> toJson() {
    return {
      'totalOrders': totalOrders,
      'pendingOrders': pendingOrders,
      'deliveredOrders': deliveredOrders,
    };
  }

  static Map<String, dynamic>? toJsonFunc(RiderMetricsDto? object) {
    return object?.toJson();
  }
}
