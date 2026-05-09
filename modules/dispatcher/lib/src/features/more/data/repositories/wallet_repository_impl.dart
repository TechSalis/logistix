import 'package:dispatcher/src/features/more/data/datasources/wallet_remote_datasource.dart';
import 'package:dispatcher/src/features/more/domain/entities/wallet.dart';
import 'package:dispatcher/src/features/more/domain/repositories/wallet_repository.dart';
import 'package:shared/shared.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource _remoteDataSource;

  WalletRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, WalletBalance>> getWalletBalance() async {
    try {
      final result = await _remoteDataSource.getWalletBalance();
      return Right(result.toEntity());
    } on NetworkException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, WalletBalance>> saveBankDetails(
      String bankCode, String accountNumber, String accountName) async {
    try {
      final result = await _remoteDataSource.saveBankDetails(
          bankCode, accountNumber, accountName);
      return Right(result.toEntity());
    } on NetworkException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SettlementResponse>> requestSettlement(
      double amount, String? narration) async {
    try {
      final result = await _remoteDataSource.requestSettlement(amount, narration);
      return Right(result.toEntity());
    } on NetworkException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
