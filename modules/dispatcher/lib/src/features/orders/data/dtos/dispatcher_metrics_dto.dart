class DispatcherMetricsDto {
  const DispatcherMetricsDto({
    this.activeOrders,
    this.unassignedOrders,
    this.assignedOrders,
    this.enRouteOrders,
    this.onlineRidersCount,
    this.busyRidersCount,
  });

  factory DispatcherMetricsDto.fromJson(Map<String, dynamic> json) {
    return DispatcherMetricsDto(
      activeOrders: json['activeOrders'] as int?,
      unassignedOrders: json['unassignedOrders'] as int?,
      assignedOrders: json['assignedOrders'] as int?,
      enRouteOrders: json['enRouteOrders'] as int?,
      onlineRidersCount: json['onlineRidersCount'] as int?,
      busyRidersCount: json['busyRidersCount'] as int?,
    );
  }

  final int? activeOrders;
  final int? unassignedOrders;
  final int? assignedOrders;
  final int? enRouteOrders;
  final int? onlineRidersCount;
  final int? busyRidersCount;

  Map<String, dynamic> toJson() {
    return {
      'activeOrders': activeOrders,
      'unassignedOrders': unassignedOrders,
      'assignedOrders': assignedOrders,
      'enRouteOrders': enRouteOrders,
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
    int? activeOrders,
    int? unassignedOrders,
    int? assignedOrders,
    int? enRouteOrders,
    int? onlineRidersCount,
    int? busyRidersCount,
  }) {
    return DispatcherMetricsDto(
      activeOrders: activeOrders ?? this.activeOrders,
      unassignedOrders: unassignedOrders ?? this.unassignedOrders,
      assignedOrders: assignedOrders ?? this.assignedOrders,
      enRouteOrders: enRouteOrders ?? this.enRouteOrders,
      onlineRidersCount: onlineRidersCount ?? this.onlineRidersCount,
      busyRidersCount: busyRidersCount ?? this.busyRidersCount,
    );
  }

  DispatcherMetricsDto merge(DispatcherMetricsDto other) {
    return copyWith(
      activeOrders: other.activeOrders ?? activeOrders,
      unassignedOrders: other.unassignedOrders ?? unassignedOrders,
      assignedOrders: other.assignedOrders ?? assignedOrders,
      enRouteOrders: other.enRouteOrders ?? enRouteOrders,
      onlineRidersCount: other.onlineRidersCount ?? onlineRidersCount,
      busyRidersCount: other.busyRidersCount ?? busyRidersCount,
    );
  }
}
