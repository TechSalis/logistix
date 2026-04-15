import 'package:shared/shared.dart';

class AnalyticsExportRequest {
  const AnalyticsExportRequest({
    this.startDate,
    this.endDate,
    this.riderId,
    this.statuses,
  });

  factory AnalyticsExportRequest.fromJson(Map<String, dynamic> json) {
    return AnalyticsExportRequest(
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      riderId: json['riderId'] as String?,
      statuses: (json['statuses'] as List<dynamic>?)
          ?.map((e) => OrderStatusX.fromString(e as String))
          .toList(),
    );
  }

  final DateTime? startDate;
  final DateTime? endDate;
  final String? riderId;
  final List<OrderStatus>? statuses;

  Map<String, dynamic> toJson() {
    return {
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      if (riderId != null) 'riderId': riderId,
      if (statuses != null && statuses!.isNotEmpty)
        'statuses': statuses!.map((e) => e.name).toList(),
    };
  }
}
