class RiderMetrics {
  const RiderMetrics({
    required this.totalOrders,
    required this.pendingOrders,
    required this.inProgressOrders,
    required this.deliveredOrders,
    required this.codExpectedToday,
    required this.onlineRiders,
    this.avgDeliveryTime,
  });

  final int totalOrders;
  final int pendingOrders;
  final int inProgressOrders;
  final int deliveredOrders;
  final double codExpectedToday;
  final int onlineRiders;
  final double? avgDeliveryTime;
}
