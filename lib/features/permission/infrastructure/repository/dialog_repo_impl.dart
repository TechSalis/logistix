import 'package:hive_flutter/hive_flutter.dart';
import 'package:logistix/core/constants/hive_constants.dart';
import 'package:logistix/core/utils/extensions/hive.dart';
import 'package:logistix/features/permission/domain/repository/dialog_repo.dart';

class HivePermissionDialogRepositoryImpl extends PermissionDialogRepository {
  HivePermissionDialogRepositoryImpl({required super.key});

  Future<Box> get box => Hive.openTrackedBox(HiveConstants.permissions);

  @override
  Future<bool> get isGranted async => (await box).get(key, defaultValue: false);

  @override
  Future<void> markAsGranted() async => (await box).put(key, true);
}
