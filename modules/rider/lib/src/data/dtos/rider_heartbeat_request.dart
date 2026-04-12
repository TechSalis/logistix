class RiderHeartbeatRequest {
  const RiderHeartbeatRequest({
    this.lat,
    this.lng,
    this.batteryLevel,
  });

  factory RiderHeartbeatRequest.fromJson(Map<String, dynamic> json) {
    return RiderHeartbeatRequest(
      lat: json['lat'] as double?,
      lng: json['lng'] as double?,
      batteryLevel: json['batteryLevel'] as int?,
    );
  }

  final double? lat;
  final double? lng;
  final int? batteryLevel;

  Map<String, dynamic> toJson() {
    return {
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (batteryLevel != null) 'batteryLevel': batteryLevel,
    };
  }
}
