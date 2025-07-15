import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

final currencyFormatter = NumberFormat.simpleCurrency(
  decimalDigits: 0,
  name: 'NGN',
);

abstract class HiveConstants {
  static const String all = 'HiveConstants';
  static const String trackedBoxes = '__tracked_boxes';
}
