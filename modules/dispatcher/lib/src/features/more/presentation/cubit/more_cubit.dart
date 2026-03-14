import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:dispatcher/src/domain/repositories/company_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared/shared.dart';

part 'more_cubit.freezed.dart';

@freezed
class MoreState with _$MoreState {
  const factory MoreState.initial() = _Initial;
  const factory MoreState.loading() = _Loading;
  const factory MoreState.loaded(
    PackageInfo packageInfo,
    Company? company,
  ) = _Loaded;
  const factory MoreState.error(String message) = _Error;
}

class MoreCubit extends Cubit<MoreState> {
  MoreCubit(
    this._logoutUseCase,
    this._userStore,
    this._companyRepository,
  ) : super(const MoreState.initial());

  final LogoutUseCase _logoutUseCase;
  final UserStore _userStore;
  final CompanyRepository _companyRepository;

  Future<void> loadAppInfo() async {
    emit(const MoreState.loading());
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final user = await _userStore.getUser();

      Company? company;
      if (user?.companyId != null) {
        final result = await _companyRepository.getCompany(user!.companyId!);
        company = result.map(
          (error) => null,
          (data) => data,
        );
      }

      emit(MoreState.loaded(packageInfo, company));
    } catch (e) {
      emit(MoreState.error(e.toString()));
    }
  }

  late final logoutEvent = AsyncRunner<AppError, void>(_logoutUseCase.call);
}
