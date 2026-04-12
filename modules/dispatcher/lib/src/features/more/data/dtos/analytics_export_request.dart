class AnalyticsExportRequest {
  const AnalyticsExportRequest({
    this.startDate,
    this.endDate,
    this.riderId,
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
    );
  }

  final DateTime? startDate;
  final DateTime? endDate;
  final String? riderId;

  Map<String, dynamic> toJson() {
    return {
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      if (riderId != null) 'riderId': riderId,
    };
  }
}
