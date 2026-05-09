import 'package:dispatcher/src/features/more/domain/entities/wallet.dart';
import 'package:shared/shared.dart';

abstract class WalletRepository {
  Future<Either<Failure, WalletBalance>> getWalletBalance();
  Future<Either<Failure, WalletBalance>> saveBankDetails(
      String bankCode, String accountNumber, String accountName);
  Future<Either<Failure, SettlementResponse>> requestSettlement(
      double amount, String? narration);
}
