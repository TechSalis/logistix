class RiderSyncRequest {
  const RiderSyncRequest({
    required this.since,
    this.limit = 200,
    this.offset = 0,
  });

  factory RiderSyncRequest.fromJson(Map<String, dynamic> json) {
    return RiderSyncRequest(
      since: (json['since'] as num).toDouble(),
      limit: json['limit'] as int? ?? 200,
      offset: json['offset'] as int? ?? 0,
    );
  }

  final double since;
  final int limit;
  final int offset;

  Map<String, dynamic> toJson() {
    return {
      'since': since,
      'limit': limit,
      'offset': offset,
    };
  }
}
