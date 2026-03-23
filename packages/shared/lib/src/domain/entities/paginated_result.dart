/// A generic paginated result container used across domain use cases.
///
/// Uses offset-based pagination for consistency and predictability.
/// - [offset]: The number of items skipped from the beginning
/// - [limit]: The maximum number of items returned in this page
/// - [total]: The total number of items available
/// - [hasMore]: Whether there are more items beyond the current page
class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.total,
    required this.offset,
    required this.limit,
  });

  final List<T> items;
  final int total;
  final int offset;
  final int limit;

  /// Returns true if there are more items available beyond the current page
  bool get hasMore => (offset + items.length) < total;

  /// The current page number (1-indexed) based on offset and limit
  int get currentPage => (offset ~/ limit) + 1;

  /// The total number of pages based on limit and total items
  int get totalPages => (total / limit).ceil();
}
