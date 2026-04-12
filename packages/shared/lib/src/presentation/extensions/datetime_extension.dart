import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

extension DateTimeRelativeExtension on DateTime {
  /// Returns a human-readable relative string for this date using timeago.
  String toRelative() {
    return timeago.format(this);
  }

  /// Returns a full formatted string: MMM dd, yyyy • hh:mm a
  String toFullString() {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(this);
  }
}
