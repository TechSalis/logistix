import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

extension DateTimeRelativeExtension on DateTime {
  /// Returns a human-readable relative string for this date using timeago.
  String toRelative() {
    return timeago.format(this).replaceAll(' ago', '');
  }

  /// Returns a full formatted string: MMM dd, yyyy • hh:mm a
  String toFullString() {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(this);
  }

  /// Returns a formatted string for scheduling, hiding time if it's 00:00.
  String toScheduleString() {
    if (hour == 0 && minute == 0) {
      return DateFormat('MMM dd, yyyy').format(this);
    }
    return toFullString();
  }
}
