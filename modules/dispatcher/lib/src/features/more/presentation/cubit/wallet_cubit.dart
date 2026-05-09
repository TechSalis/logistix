import 'package:dispatcher/src/features/more/domain/entities/wallet.dart';
import 'package:dispatcher/src/features/more/domain/repositories/wallet_repository.dart';
import 'package:dispatcher/src/features/more/presentation/cubit/wallet_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit(this._repository) : super(const WalletState.initial());
  final WalletRepository _repository;

  Future<void> fetchWalletBalance() async {
    emit(const WalletState.loading());
    final result = await _repository.getWalletBalance();
    final banksResult = await _repository.getSupportedBanks();

    final banks = banksResult.map((_) => <Bank>[], (banks) => banks);

    result.map(
      (failure) => emit(WalletState.error(failure.message ?? 'Unknown error')),
      (balance) => emit(WalletState.loaded(balance, banks)),
    );
  }

  Future<void> saveBankDetails(String code, String number, String name) async {
    final banks = state.maybeWhen(
      loaded: (_, banks) => banks,
      settlementSuccess: (_, __, banks) => banks,
      orElse: () => <Bank>[],
    );

    emit(const WalletState.loading());
    final result = await _repository.saveBankDetails(code, number, name);

    result.map(
      (failure) => emit(WalletState.error(failure.message ?? 'Unknown error')),
      (balance) => emit(WalletState.loaded(balance, banks)),
    );
  }

  Future<void> requestSettlement(double amount, String? narration) async {
    final banks = state.maybeWhen(
      loaded: (_, banks) => banks,
      settlementSuccess: (_, __, banks) => banks,
      orElse: () => <Bank>[],
    );

    emit(const WalletState.loading());
    final result = await _repository.requestSettlement(amount, narration);

    result.map(
      (failure) => emit(WalletState.error(failure.message ?? 'Unknown error')),
      (response) {
        if (response.success) {
          final newBalance = WalletBalance(
            ledgerBalance: response.remainingBalance,
            bankDetails: state.maybeWhen(
              loaded: (balance, _) => balance.bankDetails,
              settlementSuccess: (balance, _, __) => balance.bankDetails,
              orElse: () => null,
            ),
          );
          emit(
            WalletState.settlementSuccess(
              newBalance,
              response.reference,
              banks,
            ),
          );
          fetchWalletBalance();
        } else {
          emit(WalletState.error(response.message));
        }
      },
    );
  }
}
