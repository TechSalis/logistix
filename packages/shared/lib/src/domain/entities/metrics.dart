import 'package:freezed_annotation/freezed_annotation.dart';

part 'metrics.freezed.dart';

@freezed
abstract class Metrics with _$Metrics {
  const factory Metrics({
    /// Total orders created today
    required int totalOrders,

    /// Orders awaiting rider assignment
    required int pendingOrders,

    /// Orders currently assigned or en-route
    required int inProgressOrders,

    /// Orders delivered today
    required int deliveredOrders,

    /// Sum of COD amounts on active (non-delivered, non-cancelled) orders today
    required double codExpectedToday,

    /// Riders currently online and accepted
    required int onlineRiders,

    /// Average delivery time in minutes (today's delivered orders)
    double? avgDeliveryTime,
  }) = _Metrics;
}
