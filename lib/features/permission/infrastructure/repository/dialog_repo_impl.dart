import 'package:hive_flutter/hive_flutter.dart';
import 'package:logistix/core/utils/extensions/hive.dart';
import 'package:logistix/features/permission/domain/repository/dialog_repo.dart';

class HivePermissionDialogRepositoryImpl extends PermissionDialogRepository {
  HivePermissionDialogRepositoryImpl({
    required super.key,
    // required super.maxRetries,
  });

  Future<Box> get box => Hive.openTrackedBox('permissions');

  @override
  Future<bool> get isGranted async => (await box).get(key, defaultValue: false);

  @override
  Future<void> markAsGranted() async => (await box).put(key, true);

  // @override
  // Future<bool> get canShow async {
  //   if (await isGranted) return false;
  //   final retry = (await box).get('$key-retry', defaultValue: 0);
  //   return retry <= maxRetries;
  // }

  // @override
  // void wasCancelled() async {
  //   (await box).put(
  //     '$key-retry',
  //     (await box).get('$key-retry', defaultValue: 0) + 1,
  //   );
  // }
}
