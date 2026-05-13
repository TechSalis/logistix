class UpdateOrderStatusRequest {
  const UpdateOrderStatusRequest({
    required this.orderId,
    required this.status,
    this.sessionId,
    this.pin,
    this.proofImageUrl,
  });

  factory UpdateOrderStatusRequest.fromJson(Map<String, dynamic> json) {
    return UpdateOrderStatusRequest(
      orderId: json['orderId'] as String,
      status: json['status'] as String,
      sessionId: json['sessionId'] as String?,
      pin: json['pin'] as String?,
      proofImageUrl: json['proofImageUrl'] as String?,
    );
  }

  final String orderId;
  final String status;
  final String? sessionId;
  final String? pin;
  final String? proofImageUrl;

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'status': status,
      if (sessionId != null) 'sessionId': sessionId,
      if (pin != null) 'pin': pin,
      if (proofImageUrl != null) 'proofImageUrl': proofImageUrl,
    };
  }
}
