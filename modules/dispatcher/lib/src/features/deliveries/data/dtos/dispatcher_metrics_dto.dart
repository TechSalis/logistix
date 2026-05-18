class DispatcherMetricsDto {
  const DispatcherMetricsDto({
    this.activeDeliveries,
    this.unassignedDeliveries,
    this.assignedDeliveries,
    this.enRouteDeliveries,
    this.onlineRidersCount,
    this.busyRidersCount,
  });

  factory DispatcherMetricsDto.fromJson(Map<String, dynamic> json) {
    return DispatcherMetricsDto(
      activeDeliveries: json['activeDeliveries'] as int?,
      unassignedDeliveries: json['unassignedDeliveries'] as int?,
      assignedDeliveries: json['assignedDeliveries'] as int?,
      enRouteDeliveries: json['enRouteDeliveries'] as int?,
      onlineRidersCount: json['onlineRidersCount'] as int?,
      busyRidersCount: json['busyRidersCount'] as int?,
    );
  }

  final int? activeDeliveries;
  final int? unassignedDeliveries;
  final int? assignedDeliveries;
  final int? enRouteDeliveries;
  final int? onlineRidersCount;
  final int? busyRidersCount;

  Map<String, dynamic> toJson() {
    return {
      'activeDeliveries': activeDeliveries,
      'unassignedDeliveries': unassignedDeliveries,
      'assignedDeliveries': assignedDeliveries,
      'enRouteDeliveries': enRouteDeliveries,
      'onlineRidersCount': onlineRidersCount,
      'busyRidersCount': busyRidersCount,
    };
  }

  static Map<String, dynamic>? toJsonFunc(DispatcherMetricsDto? dto) =>
      dto?.toJson();

  int get totalRiders => (onlineRidersCount ?? 0) + (busyRidersCount ?? 0);
  int get activeRiders => busyRidersCount ?? 0;
  int get availableRiders => onlineRidersCount ?? 0;

  DispatcherMetricsDto copyWith({
    int? activeDeliveries,
    int? unassignedDeliveries,
    int? assignedDeliveries,
    int? enRouteDeliveries,
    int? onlineRidersCount,
    int? busyRidersCount,
  }) {
    return DispatcherMetricsDto(
      activeDeliveries: activeDeliveries ?? this.activeDeliveries,
      unassignedDeliveries: unassignedDeliveries ?? this.unassignedDeliveries,
      assignedDeliveries: assignedDeliveries ?? this.assignedDeliveries,
      enRouteDeliveries: enRouteDeliveries ?? this.enRouteDeliveries,
      onlineRidersCount: onlineRidersCount ?? this.onlineRidersCount,
      busyRidersCount: busyRidersCount ?? this.busyRidersCount,
    );
  }

  DispatcherMetricsDto merge(DispatcherMetricsDto other) {
    return copyWith(
      activeDeliveries: other.activeDeliveries ?? activeDeliveries,
      unassignedDeliveries: other.unassignedDeliveries ?? unassignedDeliveries,
      assignedDeliveries: other.assignedDeliveries ?? assignedDeliveries,
      enRouteDeliveries: other.enRouteDeliveries ?? enRouteDeliveries,
      onlineRidersCount: other.onlineRidersCount ?? onlineRidersCount,
      busyRidersCount: other.busyRidersCount ?? busyRidersCount,
    );
  }
}
