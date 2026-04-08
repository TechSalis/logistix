import 'dart:io';

import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/extensions/result_extensions.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:dispatcher/src/domain/usecases/export_analytics_usecase.dart';
import 'package:dispatcher/src/domain/usecases/request_integration_usecase.dart';
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
  const factory MoreState.loaded({
    required PackageInfo packageInfo,
    required User? user,
  }) = _Loaded;
  const factory MoreState.error(String message) = _Error;
}

class MoreCubit extends Cubit<MoreState> {
  MoreCubit(
    this._authStatusRepository,
    this._userStore,
    this._exportAnalyticsUseCase,
    this._requestIntegrationUseCase,
  ) : super(const MoreState.initial());

  final AuthStatusRepository _authStatusRepository;
  final UserStore _userStore;
  final ExportAnalyticsUseCase _exportAnalyticsUseCase;
  final RequestIntegrationUseCase _requestIntegrationUseCase;

  Future<void> loadAppInfo() async {
    emit(const MoreState.loading());
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final user = await _userStore.getUser();

      emit(MoreState.loaded(packageInfo: packageInfo, user: user));
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

  late final requestIntegrationRunner =
      AsyncRunner.withArg<ActivationRequestDto, AppError, void>((request) async {
        final result = await _requestIntegrationUseCase(request);
        return result.throwOrReturn();
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
