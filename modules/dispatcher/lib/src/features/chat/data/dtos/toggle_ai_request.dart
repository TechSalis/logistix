class ToggleAiRequest {
  const ToggleAiRequest({
    required this.conversationId,
    required this.enabled,
  });

  factory ToggleAiRequest.fromJson(Map<String, dynamic> json) {
    return ToggleAiRequest(
      conversationId: json['conversationId'] as String,
      enabled: json['enabled'] as bool,
    );
  }

  final String conversationId;
  final bool enabled;

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'enabled': enabled,
    };
  }
}
