class AssignOrderRequest {
  const AssignOrderRequest({
    required this.orderId,
    required this.riderId,
    this.sessionId,
  });

  factory AssignOrderRequest.fromJson(Map<String, dynamic> json) {
    return AssignOrderRequest(
      orderId: json['orderId'] as String,
      riderId: json['riderId'] as String,
      sessionId: json['sessionId'] as String?,
    );
  }

  final String orderId;
  final String riderId;
  final String? sessionId;

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'riderId': riderId,
      if (sessionId != null) 'sessionId': sessionId,
    };
  }
}
