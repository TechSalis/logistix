import 'package:dispatcher/src/features/more/data/dtos/wallet_dto.dart';
import 'package:shared/shared.dart';

abstract class WalletRemoteDataSource {
  Future<WalletBalanceDto> getWalletBalance();
  Future<WalletBalanceDto> saveBankDetails(String bankCode, String accountNumber, String accountName);
  Future<SettlementResponseDto> requestSettlement(double amount, String? narration);
  Future<List<BankDto>> getSupportedBanks();
}

class WalletRemoteDataSourceImpl extends BaseRemoteDataSource implements WalletRemoteDataSource {
  WalletRemoteDataSourceImpl(super.gqlService);

  @override
  Future<List<BankDto>> getSupportedBanks() async {
    const queryDoc = '''
      query GetSupportedBanks {
        supportedBanks {
          bankCode
          bankName
        }
      }
    ''';

    final result = await query<List<dynamic>>(
      queryDoc,
      key: 'supportedBanks',
    );

    return result.map((e) => BankDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<WalletBalanceDto> getWalletBalance() async {
    const queryDoc = '''
      query GetWalletBalance {
        walletBalance {
          ledgerBalance
          bankDetails {
            code
            number
            name
          }
        }
      }
    ''';

    final result = await query<Map<String, dynamic>>(
      queryDoc,
      key: 'walletBalance',
    );

    return WalletBalanceDto.fromJson(result);
  }

  @override
  Future<WalletBalanceDto> saveBankDetails(String bankCode, String accountNumber, String accountName) async {
    const mutationDoc = r'''
      mutation SaveBankDetails($bankCode: String!, $accountNumber: String!, $accountName: String) {
        saveBankDetails(bankCode: $bankCode, accountNumber: $accountNumber, accountName: $accountName) {
          ledgerBalance
          bankDetails {
            code
            number
            name
          }
        }
      }
    ''';

    final result = await mutate<Map<String, dynamic>>(
      mutationDoc,
      variables: {
        'bankCode': bankCode,
        'accountNumber': accountNumber,
        'accountName': accountName,
      },
      key: 'saveBankDetails',
    );

    return WalletBalanceDto.fromJson(result);
  }

  @override
  Future<SettlementResponseDto> requestSettlement(double amount, String? narration) async {
    const mutationDoc = r'''
      mutation RequestSettlement($amount: Float!, $narration: String) {
        requestSettlement(amount: $amount, narration: $narration) {
          success
          reference
          message
          remainingBalance
        }
      }
    ''';

    final result = await mutate<Map<String, dynamic>>(
      mutationDoc,
      variables: {
        'amount': amount,
        'narration': narration,
      },
      key: 'requestSettlement',
    );

    return SettlementResponseDto.fromJson(result);
  }
}
