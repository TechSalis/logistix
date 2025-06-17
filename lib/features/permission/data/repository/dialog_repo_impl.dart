import 'package:hive_flutter/hive_flutter.dart';
import 'package:logistix/features/permission/domain/repository/dialog_repo.dart';

class DialogHiveRepositoryImpl implements DialogRepository {
  @override
  final String key;

  DialogHiveRepositoryImpl({required this.key});

  Future<Box> get box => Hive.openBox('dialogs');

  @override
  Future<bool> isGranted() async => (await box).get(key, defaultValue: false);

  @override
  Future<void> markAsGranted() async => (await box).put(key, true);
}
