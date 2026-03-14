extension StreamExtension on Stream<dynamic> {
  Stream<T> whereType<T>() {
    return where((event) => event is T).cast<T>();
  }
}
