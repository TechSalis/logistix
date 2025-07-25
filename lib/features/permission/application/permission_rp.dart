import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/permission/domain/repository/dialog_repo.dart';
import 'package:logistix/features/permission/domain/repository/settings_service.dart';
import 'package:logistix/features/permission/infrastructure/repository/location_settings_service_impl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logistix/features/permission/infrastructure/repository/dialog_repo_impl.dart';
import 'package:logistix/features/permission/presentation/widgets/base_permission_dialog.dart';

final _dialogHiveRepository = Provider.autoDispose
    .family<PermissionDialogRepository, String>((ref, key) {
      return HivePermissionDialogRepositoryImpl(key: key);
    });

final locationSettingsProvider = Provider.autoDispose<SettingsService>(
  (ref) => LocationSettingsImpl(),
);

class PermissionState extends Equatable {
  const PermissionState({this.isGranted, this.status});

  final bool? isGranted;
  final PermissionStatus? status;

  PermissionState copyWith({bool? isGranted, PermissionStatus? status}) {
    return PermissionState(
      isGranted: isGranted ?? this.isGranted,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [isGranted, status];
}

class PermissionNotifier
    extends AutoDisposeFamilyNotifier<PermissionState, PermissionData> {
  PermissionNotifier();

  @override
  bool updateShouldNotify(previous, next) => previous != next;

  @override
  PermissionState build(PermissionData arg) {
    ref.watch(_dialogHiveRepository(arg.name)).isGranted.then((value) async {
      state = PermissionState(
        isGranted: value ?? false,
        status: value != null ? await arg.permission.status : null,
      );
    });
    return const PermissionState();
  }

  void setHasGranted() {
    state = state.copyWith(isGranted: true);
    ref.read(_dialogHiveRepository(arg.name)).markAsGranted();
  }

  Future<bool> request() async {
    final status = await arg.permission.request();
    state = state.copyWith(isGranted: status.isGranted, status: status);

    if (status.isGranted) {
      ref.read(_dialogHiveRepository(arg.name)).markAsGranted();
    }
    return status.isGranted;
  }
}

final permissionProvider = NotifierProvider.autoDispose.family(
  PermissionNotifier.new,
);
