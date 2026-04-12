class UpdateOrderStatusRequest {
  const UpdateOrderStatusRequest({
    required this.orderId,
    required this.status,
    this.sessionId,
  });

  factory UpdateOrderStatusRequest.fromJson(Map<String, dynamic> json) {
    return UpdateOrderStatusRequest(
      orderId: json['orderId'] as String,
      status: json['status'] as String,
      sessionId: json['sessionId'] as String?,
    );
  }

  final String orderId;
  final String status;
  final String? sessionId;

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'status': status,
      if (sessionId != null) 'sessionId': sessionId,
    };
  }
}
