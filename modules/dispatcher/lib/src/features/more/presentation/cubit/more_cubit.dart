import 'dart:io';

import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/extensions/result_extensions.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:dispatcher/src/features/more/data/dtos/activation_request_dto.dart';
import 'package:dispatcher/src/features/more/domain/usecases/export_analytics_usecase.dart';
import 'package:dispatcher/src/features/more/domain/usecases/get_integrations_usecase.dart';
import 'package:dispatcher/src/features/more/domain/usecases/request_integration_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared/shared.dart';

abstract class MoreState {
  const MoreState();

  const factory MoreState.initial() = MoreInitial;
  const factory MoreState.loading() = MoreLoading;
  const factory MoreState.loaded({
    required PackageInfo packageInfo,
    User? user,
  }) = MoreLoaded;
  const factory MoreState.error(String message) = MoreError;

  T? whenOrNull<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(PackageInfo packageInfo, User? user)? loaded,
    T Function(String message)? error,
  }) {
    if (this is MoreInitial) return initial?.call();
    if (this is MoreLoading) return loading?.call();
    if (this is MoreLoaded) {
      final state = this as MoreLoaded;
      return loaded?.call(state.packageInfo, state.user);
    }
    if (this is MoreError) return error?.call((this as MoreError).message);
    return null;
  }

  T maybeWhen<T>({
    required T Function() orElse, T Function()? initial,
    T Function()? loading,
    T Function(PackageInfo packageInfo, User? user)? loaded,
    T Function(String message)? error,
  }) {
    return whenOrNull(
      initial: initial,
      loading: loading,
      loaded: loaded,
      error: error,
    ) ?? orElse();
  }
}

class MoreInitial extends MoreState {
  const MoreInitial();
}

class MoreLoading extends MoreState {
  const MoreLoading();
}

class MoreLoaded extends MoreState {
  const MoreLoaded({required this.packageInfo, this.user});
  final PackageInfo packageInfo;
  final User? user;
}

class MoreError extends MoreState {
  const MoreError(this.message);
  final String message;
}

class MoreCubit extends Cubit<MoreState> {
  MoreCubit(
    this._userStore,
    this._exportAnalyticsUseCase,
    this._requestIntegrationUseCase,
    this._getIntegrationsUseCase,
    this._logoutUseCase,
  ) : super(const MoreState.initial());

  final UserStore _userStore;
  final ExportAnalyticsUseCase _exportAnalyticsUseCase;
  final RequestIntegrationUseCase _requestIntegrationUseCase;
  final GetIntegrationsUseCase _getIntegrationsUseCase;
  final LogoutUseCase _logoutUseCase;

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

  late final logoutRunner = AsyncRunner<AppError, void>(() async {
    final result = await _logoutUseCase();
    return result.throwOrReturn();
  });

  late final exportAnalyticsRunner =
      AsyncRunner.withArg<ExportParams, AppError, String>((params) async {
        final result = await _exportAnalyticsUseCase(
          startDate: params.startDate,
          endDate: params.endDate,
          riderId: params.riderId,
          statuses: params.statuses,
        );
        final csv = result.throwOrReturn();
        return _saveToTempFile(csv, 'analytics_export');
      });

  late final requestIntegrationRunner =
      AsyncRunner.withArg<ActivationRequestDto, AppError, void>((request) async {
        final result = await _requestIntegrationUseCase(request);
        final integration = result.throwOrReturn();

        state.whenOrNull(
          loaded: (info, user) {
            if (user == null) return;
            final company = user.companyProfile;
            if (company == null) return;

            final integrations = List<CompanyIntegration>.from(
              company.integrations ?? [],
            );

            // Replace or add the integration
            final existingIndex = integrations.indexWhere(
              (e) => e.platform == integration.platform,
            );
            if (existingIndex >= 0) {
              integrations[existingIndex] = integration;
            } else {
              integrations.add(integration);
            }

            final updatedUser = user.copyWith(
              companyProfile: company.copyWith(integrations: integrations),
            );

            _userStore.saveUser(updatedUser);
            emit(MoreState.loaded(packageInfo: info, user: updatedUser));
          },
        );
      });

  late final fetchIntegrationsRunner =
      AsyncRunner<AppError, List<CompanyIntegration>>(() async {
        final result = await _getIntegrationsUseCase();
        final integrations = result.throwOrReturn();

        state.whenOrNull(
          loaded: (info, user) {
            if (user == null) return;
            final updatedUser = user.copyWith(
              companyProfile: user.companyProfile?.copyWith(
                integrations: integrations,
              ),
            );
            _userStore.saveUser(updatedUser);
            emit(MoreState.loaded(packageInfo: info, user: updatedUser));
          },
        );

        return integrations;
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
  ExportParams({this.startDate, this.endDate, this.riderId, this.statuses});
  final DateTime? startDate;
  final DateTime? endDate;
  final String? riderId;
  final List<OrderStatus>? statuses;
}
