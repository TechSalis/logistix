import 'package:shared/src/domain/entities/weekday.dart';

class DayConfig {
  const DayConfig({
    required this.start,
    required this.close,
  });

  factory DayConfig.fromJson(Map<String, dynamic> json) {
    return DayConfig(
      start: json['start'] as String,
      close: json['close'] as String,
    );
  }

  final String start;
  final String close;

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

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      monday: json[Weekday.monday] != null
          ? DayConfig.fromJson(json[Weekday.monday] as Map<String, dynamic>)
          : null,
      tuesday: json[Weekday.tuesday] != null
          ? DayConfig.fromJson(json[Weekday.tuesday] as Map<String, dynamic>)
          : null,
      wednesday: json[Weekday.wednesday] != null
          ? DayConfig.fromJson(json[Weekday.wednesday] as Map<String, dynamic>)
          : null,
      thursday: json[Weekday.thursday] != null
          ? DayConfig.fromJson(json[Weekday.thursday] as Map<String, dynamic>)
          : null,
      friday: json[Weekday.friday] != null
          ? DayConfig.fromJson(json[Weekday.friday] as Map<String, dynamic>)
          : null,
      saturday: json[Weekday.saturday] != null
          ? DayConfig.fromJson(json[Weekday.saturday] as Map<String, dynamic>)
          : null,
      sunday: json[Weekday.sunday] != null
          ? DayConfig.fromJson(json[Weekday.sunday] as Map<String, dynamic>)
          : null,
    );
  }

  final DayConfig? monday;
  final DayConfig? tuesday;
  final DayConfig? wednesday;
  final DayConfig? thursday;
  final DayConfig? friday;
  final DayConfig? saturday;
  final DayConfig? sunday;

  DayConfig? getDayConfig(String day) {
    if (day == Weekday.monday) return monday;
    if (day == Weekday.tuesday) return tuesday;
    if (day == Weekday.wednesday) return wednesday;
    if (day == Weekday.thursday) return thursday;
    if (day == Weekday.friday) return friday;
    if (day == Weekday.saturday) return saturday;
    if (day == Weekday.sunday) return sunday;
    return null;
  }

  WorkingHours setDayConfig(String day, DayConfig? config) {
    if (day == Weekday.monday) return copyWith(monday: config);
    if (day == Weekday.tuesday) return copyWith(tuesday: config);
    if (day == Weekday.wednesday) return copyWith(wednesday: config);
    if (day == Weekday.thursday) return copyWith(thursday: config);
    if (day == Weekday.friday) return copyWith(friday: config);
    if (day == Weekday.saturday) return copyWith(saturday: config);
    if (day == Weekday.sunday) return copyWith(sunday: config);
    return this;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (monday != null) map[Weekday.monday] = monday!.toJson();
    if (tuesday != null) map[Weekday.tuesday] = tuesday!.toJson();
    if (wednesday != null) map[Weekday.wednesday] = wednesday!.toJson();
    if (thursday != null) map[Weekday.thursday] = thursday!.toJson();
    if (friday != null) map[Weekday.friday] = friday!.toJson();
    if (saturday != null) map[Weekday.saturday] = saturday!.toJson();
    if (sunday != null) map[Weekday.sunday] = sunday!.toJson();
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

  static const WorkingHours defaultSchedule = WorkingHours(
    monday: DayConfig(start: '07:00', close: '19:00'),
    tuesday: DayConfig(start: '07:00', close: '19:00'),
    wednesday: DayConfig(start: '07:00', close: '19:00'),
    thursday: DayConfig(start: '07:00', close: '19:00'),
    friday: DayConfig(start: '07:00', close: '19:00'),
    saturday: DayConfig(start: '07:00', close: '19:00'),
      );
}
