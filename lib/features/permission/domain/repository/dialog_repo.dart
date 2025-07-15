abstract class PermissionDialogRepository {
  PermissionDialogRepository({required this.key});

  final String key;
  // final int maxRetries;

  // Future<bool> get canShow;
  // void wasCancelled();

  Future<bool> get isGranted;
  Future<void> markAsGranted();
}
