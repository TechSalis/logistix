import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:dispatcher/src/features/more/domain/entities/wallet.dart';

abstract class WalletRepository {
  Future<Result<AppError, WalletBalance>> getWalletBalance();
  Future<Result<AppError, WalletBalance>> saveBankDetails(
      String bankCode, String accountNumber, String accountName);
  Future<Result<AppError, SettlementResponse>> requestSettlement(
      double amount, String? narration);
  Future<Result<AppError, List<Bank>>> getSupportedBanks();
}
