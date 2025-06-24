import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class AppNotificationData extends Equatable {
  const AppNotificationData();
  NotificationKey? get key;
}

class NotificationKey<T extends AppNotificationData> extends LocalKey {
  final T value;
  const NotificationKey(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationKey<T> && other.value == value;

  @override
  int get hashCode => Object.hash(runtimeType, value);
}
