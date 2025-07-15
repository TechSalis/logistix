import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/permission/domain/repository/dialog_repo.dart';
import 'package:logistix/features/permission/domain/repository/settings_service.dart';
import 'package:logistix/features/permission/infrastructure/repository/location_settings_service_impl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logistix/features/permission/infrastructure/repository/dialog_repo_impl.dart';
import 'package:logistix/features/permission/presentation/widgets/permission_dialog.dart';

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
  // final bool? canShow;
  final PermissionStatus? status;

  PermissionState copyWith({
    bool? isGranted,
    // bool? canShow,
    PermissionStatus? status,
  }) {
    return PermissionState(
      isGranted: isGranted ?? this.isGranted,
      // canShow: canShow ?? this.canShow,
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
    () async {
      state = PermissionState(
        isGranted: await ref.read(_dialogHiveRepository(arg.name)).isGranted,
        // canShow: await ref.read(_dialogHiveRepository(arg.name)).canShow,
      );
    }();

    return const PermissionState();
  }

  void setHasGranted() {
    state = state.copyWith(isGranted: true);
    ref.read(_dialogHiveRepository(arg.name)).markAsGranted();
  }

  // void wasCanclled() {
  //   ref.read(_dialogHiveRepository(arg.name)).wasCancelled();
  // }

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
