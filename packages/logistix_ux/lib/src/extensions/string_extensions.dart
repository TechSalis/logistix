import 'package:flutter/widgets.dart';

extension LogistixStringExtensions on String {
  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    final firstChar = characters.firstOrNull;
    if (firstChar == null) return this;
    return '${firstChar.toUpperCase()}${substring(firstChar.length)}';
  }

  /// Capitalize first letter of each word
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Get up to two initials from a name safely
  String get initials {
    if (trim().isEmpty) return '?';
    return trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .map((e) => e.characters.firstOrNull?.toUpperCase() ?? '')
        .take(2)
        .join();
  }

  /// Remove all whitespace
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Check if string contains only numbers
  bool get isNumeric => double.tryParse(this) != null;

  /// Truncate string with ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$ellipsis';
  }

  /// Reverse string
  String get reverse => split('').reversed.join();

  /// Check if string is null or empty
  bool get isNullOrEmpty => isEmpty;

  /// Check if string is not null and not empty
  bool get isNotNullOrEmpty => isNotEmpty;
}

extension LogistixNullableStringExtensions on String? {
  /// Check if string is null or empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Check if string is not null and not empty
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// Get string or default value
  String orDefault([String defaultValue = '']) => this ?? defaultValue;
}
