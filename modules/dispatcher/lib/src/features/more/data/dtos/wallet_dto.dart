import 'package:dispatcher/src/features/more/domain/entities/wallet.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_dto.freezed.dart';
part 'wallet_dto.g.dart';

class BankDetailsDto {
  const BankDetailsDto({
    required this.code,
    required this.number,
    required this.name,
  });

  factory BankDetailsDto.fromJson(Map<String, dynamic> json) {
    return BankDetailsDto(
      code: json['code'] as String,
      number: json['number'] as String,
      name: json['name'] as String,
    );
  }

  final String code;
  final String number;
  final String name;

  BankDetails toEntity() {
    return BankDetails(code: code, number: number, name: name);
  }
}

class WalletBalanceDto {
  const WalletBalanceDto({required this.ledgerBalance, this.bankDetails});

  factory WalletBalanceDto.fromJson(Map<String, dynamic> json) {
    return WalletBalanceDto(
      ledgerBalance: (json['ledgerBalance'] as num).toDouble(),
      bankDetails: json['bankDetails'] != null
          ? BankDetailsDto.fromJson(json['bankDetails'] as Map<String, dynamic>)
          : null,
    );
  }
  final double ledgerBalance;
  final BankDetailsDto? bankDetails;

  WalletBalance toEntity() {
    return WalletBalance(
      ledgerBalance: ledgerBalance,
      bankDetails: bankDetails?.toEntity(),
    );
  }
}

class SettlementResponseDto {
  const SettlementResponseDto({
    required this.success,
    required this.reference,
    required this.message,
    required this.remainingBalance,
  });

  factory SettlementResponseDto.fromJson(Map<String, dynamic> json) {
    return SettlementResponseDto(
      success: json['success'] as bool,
      reference: json['reference'] as String,
      message: json['message'] as String,
      remainingBalance: (json['remainingBalance'] as num).toDouble(),
    );
  }
  final bool success;
  final String reference;
  final String message;
  final double remainingBalance;

  SettlementResponse toEntity() {
    return SettlementResponse(
      success: success,
      reference: reference,
      message: message,
      remainingBalance: remainingBalance,
    );
  }
}

@freezed
abstract class BankDto with _$BankDto {
  const factory BankDto({required String bankCode, required String bankName}) =
      _BankDto;

  factory BankDto.fromJson(Map<String, dynamic> json) =>
      _$BankDtoFromJson(json);

  const BankDto._();

  Bank toEntity() => Bank(bankCode: bankCode, bankName: bankName);
}
