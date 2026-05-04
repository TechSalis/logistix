class DayConfig {
  const DayConfig({
    required this.start,
    required this.close,
  });

  final String start;
  final String close;

  factory DayConfig.fromJson(Map<String, dynamic> json) {
    return DayConfig(
      start: json['start'] as String,
      close: json['close'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'close': close,
    };
  }

  DayConfig copyWith({
    String? start,
    String? close,
  }) {
    return DayConfig(
      start: start ?? this.start,
      close: close ?? this.close,
    );
  }
}

class WorkingHours {
  const WorkingHours({
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
    this.sunday,
  });

  final DayConfig? monday;
  final DayConfig? tuesday;
  final DayConfig? wednesday;
  final DayConfig? thursday;
  final DayConfig? friday;
  final DayConfig? saturday;
  final DayConfig? sunday;

  DayConfig? getDayConfig(String day) {
    switch (day) {
      case 'Monday': return monday;
      case 'Tuesday': return tuesday;
      case 'Wednesday': return wednesday;
      case 'Thursday': return thursday;
      case 'Friday': return friday;
      case 'Saturday': return saturday;
      case 'Sunday': return sunday;
      default: return null;
    }
  }

  WorkingHours setDayConfig(String day, DayConfig? config) {
    switch (day) {
      case 'Monday': return copyWith(monday: config);
      case 'Tuesday': return copyWith(tuesday: config);
      case 'Wednesday': return copyWith(wednesday: config);
      case 'Thursday': return copyWith(thursday: config);
      case 'Friday': return copyWith(friday: config);
      case 'Saturday': return copyWith(saturday: config);
      case 'Sunday': return copyWith(sunday: config);
      default: return this;
    }
  }

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      monday: json['Monday'] != null ? DayConfig.fromJson(json['Monday'] as Map<String, dynamic>) : null,
      tuesday: json['Tuesday'] != null ? DayConfig.fromJson(json['Tuesday'] as Map<String, dynamic>) : null,
      wednesday: json['Wednesday'] != null ? DayConfig.fromJson(json['Wednesday'] as Map<String, dynamic>) : null,
      thursday: json['Thursday'] != null ? DayConfig.fromJson(json['Thursday'] as Map<String, dynamic>) : null,
      friday: json['Friday'] != null ? DayConfig.fromJson(json['Friday'] as Map<String, dynamic>) : null,
      saturday: json['Saturday'] != null ? DayConfig.fromJson(json['Saturday'] as Map<String, dynamic>) : null,
      sunday: json['Sunday'] != null ? DayConfig.fromJson(json['Sunday'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (monday != null) map['Monday'] = monday!.toJson();
    if (tuesday != null) map['Tuesday'] = tuesday!.toJson();
    if (wednesday != null) map['Wednesday'] = wednesday!.toJson();
    if (thursday != null) map['Thursday'] = thursday!.toJson();
    if (friday != null) map['Friday'] = friday!.toJson();
    if (saturday != null) map['Saturday'] = saturday!.toJson();
    if (sunday != null) map['Sunday'] = sunday!.toJson();
    return map;
  }

  WorkingHours copyWith({
    DayConfig? monday,
    DayConfig? tuesday,
    DayConfig? wednesday,
    DayConfig? thursday,
    DayConfig? friday,
    DayConfig? saturday,
    DayConfig? sunday,
  }) {
    return WorkingHours(
      monday: monday ?? this.monday,
      tuesday: tuesday ?? this.tuesday,
      wednesday: wednesday ?? this.wednesday,
      thursday: thursday ?? this.thursday,
      friday: friday ?? this.friday,
      saturday: saturday ?? this.saturday,
      sunday: sunday ?? this.sunday,
    );
  }

  static WorkingHours get defaultSchedule => WorkingHours(
        monday: const DayConfig(start: '07:00', close: '19:00'),
        tuesday: const DayConfig(start: '07:00', close: '19:00'),
        wednesday: const DayConfig(start: '07:00', close: '19:00'),
        thursday: const DayConfig(start: '07:00', close: '19:00'),
        friday: const DayConfig(start: '07:00', close: '19:00'),
        saturday: const DayConfig(start: '07:00', close: '19:00'),
      );
}
