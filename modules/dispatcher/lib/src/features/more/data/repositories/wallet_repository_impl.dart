import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:dispatcher/src/features/more/data/datasources/wallet_remote_datasource.dart';
import 'package:dispatcher/src/features/more/domain/entities/wallet.dart';
import 'package:dispatcher/src/features/more/domain/repositories/wallet_repository.dart';
import 'package:shared/shared.dart';

class WalletRepositoryImpl implements WalletRepository {
  WalletRepositoryImpl(this._remoteDataSource);
  final WalletRemoteDataSource _remoteDataSource;

  @override
  Future<Result<AppError, WalletBalance>> getWalletBalance() async {
    try {
      final result = await _remoteDataSource.getWalletBalance();
      return Result.data(result.toEntity());
    } catch (e, s) {
      return Result.error(ErrorHandler.fromException(e, s));
    }
  }

  @override
  Future<Result<AppError, WalletBalance>> saveBankDetails(
      String bankCode, String accountNumber, String accountName) async {
    try {
      final result = await _remoteDataSource.saveBankDetails(
          bankCode, accountNumber, accountName);
      return Result.data(result.toEntity());
    } catch (e, s) {
      return Result.error(ErrorHandler.fromException(e, s));
    }
  }

  @override
  Future<Result<AppError, SettlementResponse>> requestSettlement(
      double amount, String? narration) async {
    try {
      final result = await _remoteDataSource.requestSettlement(amount, narration);
      return Result.data(result.toEntity());
    } catch (e, s) {
      return Result.error(ErrorHandler.fromException(e, s));
    }
  }

  @override
  Future<Result<AppError, List<Bank>>> getSupportedBanks() async {
    try {
      final result = await _remoteDataSource.getSupportedBanks();
      return Result.data(result.map((e) => e.toEntity()).toList());
    } catch (e, s) {
      return Result.error(ErrorHandler.fromException(e, s));
    }
  }
}
