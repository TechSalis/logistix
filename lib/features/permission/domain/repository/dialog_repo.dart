abstract class DialogRepository {
  final String key;
  DialogRepository({required this.key});

  Future<bool?> isGranted();
  Future<void> markAsGranted();
}
