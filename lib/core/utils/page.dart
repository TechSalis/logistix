class PageData {
  final int index;
  final int size;
  final bool isLast;

  const PageData({
    required this.index,
    required this.size,
    required this.isLast,
  });

  Map<String, dynamic> toJson() => {'page': index, 'size': size};

  PageData next({bool isLast = false}) {
    return PageData(index: index + 1, size: size, isLast: isLast);
  }
}
