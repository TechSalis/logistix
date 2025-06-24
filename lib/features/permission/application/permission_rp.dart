import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/permission/domain/repository/settings_service.dart';
import 'package:logistix/features/permission/infrastructure/repository/location_settings_service_impl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logistix/features/permission/infrastructure/repository/dialog_repo_impl.dart';
import 'package:logistix/features/permission/presentation/widgets/permission_dialog.dart';

final _dialogHiveRepository = Provider.family.autoDispose(
  (ref, String key) => DialogHiveRepositoryImpl(key: key),
);

final locationSettingsProvider = Provider.autoDispose<SettingsService>(
  (ref) => LocationSettingsImpl(),
);

class PermissionState extends Equatable {
  const PermissionState([this.isGranted = false, this.status]);

  final bool isGranted;
  final PermissionStatus? status;

  PermissionState copyWith({bool? isGranted, PermissionStatus? status}) {
    return PermissionState(isGranted ?? this.isGranted, status ?? this.status);
  }

  @override
  List<Object?> get props => [isGranted, status];
}

class PermissionNotifier
    extends AutoDisposeFamilyAsyncNotifier<PermissionState, PermissionData> {
  PermissionNotifier();

  @override
  bool updateShouldNotify(previous, next) => previous != next;

  @override
  Future<PermissionState> build(PermissionData arg) async {
    final hasShown =
        await ref.read(_dialogHiveRepository(arg.name)).isGranted();
    return PermissionState(hasShown);
  }

  void setHasGranted() {
    state = AsyncValue.data(
      (state.value ?? const PermissionState()).copyWith(isGranted: true),
    );
    ref.read(_dialogHiveRepository(arg.name)).markAsGranted();
  }

  Future requestPermission() async {
    final permission = await arg.permission.request();
    state = AsyncValue.data(PermissionState(permission.isGranted, permission));
    if (permission.isGranted) {
      ref.read(_dialogHiveRepository(arg.name)).markAsGranted();
    }
  }
}

final permissionProvider = AsyncNotifierProvider.family.autoDispose(
  PermissionNotifier.new,
);
