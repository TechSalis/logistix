import 'dart:io';

import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/extensions/result_extensions.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:dispatcher/src/domain/usecases/export_analytics_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared/shared.dart';

part 'more_cubit.freezed.dart';

@freezed
class MoreState with _$MoreState {
  const factory MoreState.initial() = _Initial;
  const factory MoreState.loading() = _Loading;
  const factory MoreState.loaded(PackageInfo packageInfo, Company? company) =
      _Loaded;
  const factory MoreState.error(String message) = _Error;
}

class MoreCubit extends Cubit<MoreState> {
  MoreCubit(
    this._authStatusRepository,
    this._userStore,
    this._exportAnalyticsUseCase,
  ) : super(const MoreState.initial());

  final AuthStatusRepository _authStatusRepository;
  final UserStore _userStore;
  final ExportAnalyticsUseCase _exportAnalyticsUseCase;

  Future<void> loadAppInfo() async {
    emit(const MoreState.loading());
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final user = await _userStore.getUser();

      Company? company;
      if (user?.companyProfile != null) {
        company = user!.companyProfile;
      }

      emit(MoreState.loaded(packageInfo, company));
    } catch (e) {
      emit(MoreState.error(e.toString()));
    }
  }

  void logout() => _authStatusRepository.setUnauthenticated();

  late final exportAnalyticsRunner =
      AsyncRunner.withArg<ExportParams, AppError, String>((params) async {
        final result = await _exportAnalyticsUseCase(
          startDate: params.startDate,
          endDate: params.endDate,
          riderId: params.riderId,
        );
        final csv = result.throwOrReturn();
        return _saveToTempFile(csv, 'analytics_export');
      });

  Future<String> _saveToTempFile(String content, String prefix) async {
    final tempDir = await getTemporaryDirectory();
    final file = File(
      '${tempDir.path}/${prefix}_${DateTime.now().millisecondsSinceEpoch}.csv',
    );
    await file.writeAsString(content);
    return file.path;
  }
}

class ExportParams {
  ExportParams({this.startDate, this.endDate, this.riderId});
  final DateTime? startDate;
  final DateTime? endDate;
  final String? riderId;
}
