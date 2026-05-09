import 'package:dispatcher/src/features/more/domain/entities/wallet.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_state.freezed.dart';

@freezed
class WalletState with _$WalletState {
  const factory WalletState.initial() = _Initial;
  const factory WalletState.loading() = _Loading;
  const factory WalletState.loaded(WalletBalance balance) = _Loaded;
  const factory WalletState.error(String message) = _Error;
  const factory WalletState.settlementSuccess(WalletBalance newBalance, String reference) = _SettlementSuccess;
}
