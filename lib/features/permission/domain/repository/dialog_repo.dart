abstract class PermissionDialogRepository {
  PermissionDialogRepository({required this.key});
  final String key;

  Future<bool?> get isGranted;
  Future<void> markAsGranted();
}
