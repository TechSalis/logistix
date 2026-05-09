import 'package:dispatcher/src/features/more/domain/entities/wallet.dart';
import 'package:dispatcher/src/features/more/domain/repositories/wallet_repository.dart';
import 'package:dispatcher/src/features/more/presentation/cubit/wallet_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletCubit extends Cubit<WalletState> {
  final WalletRepository _repository;

  WalletCubit(this._repository) : super(const WalletState.initial());

  Future<void> fetchWalletBalance() async {
    emit(const WalletState.loading());
    final result = await _repository.getWalletBalance();
    
    result.fold(
      (failure) => emit(WalletState.error(failure.message)),
      (balance) => emit(WalletState.loaded(balance)),
    );
  }

  Future<void> saveBankDetails(String code, String number, String name) async {
    // Preserve current balance if available
    final currentState = state;
    WalletBalance? currentBalance;
    if (currentState is _Loaded) {
      currentBalance = currentState.balance;
    } else if (currentState is _SettlementSuccess) {
      currentBalance = currentState.newBalance;
    }

    emit(const WalletState.loading());
    final result = await _repository.saveBankDetails(code, number, name);
    
    result.fold(
      (failure) => emit(WalletState.error(failure.message)),
      (balance) => emit(WalletState.loaded(balance)),
    );
  }

  Future<void> requestSettlement(double amount, String? narration) async {
    emit(const WalletState.loading());
    final result = await _repository.requestSettlement(amount, narration);
    
    result.fold(
      (failure) => emit(WalletState.error(failure.message)),
      (response) {
        if (response.success) {
          // Re-fetch or manually update the local balance entity. Let's just create a new one:
          final newBalance = WalletBalance(
            ledgerBalance: response.remainingBalance,
            bankDetails: null, // Since we don't have the bank details in the response, we might need to fetch immediately.
          );
          emit(WalletState.settlementSuccess(newBalance, response.reference));
          // Refresh the balance completely to get full BankDetails back
          fetchWalletBalance();
        } else {
          emit(WalletState.error(response.message));
        }
      },
    );
  }
}
