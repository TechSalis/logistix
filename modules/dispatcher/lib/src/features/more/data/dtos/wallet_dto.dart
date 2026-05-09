import 'package:dispatcher/src/features/more/domain/entities/wallet.dart';

class BankDetailsDto {
  final String code;
  final String number;
  final String name;

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

  BankDetails toEntity() {
    return BankDetails(
      code: code,
      number: number,
      name: name,
    );
  }
}

class WalletBalanceDto {
  final double ledgerBalance;
  final BankDetailsDto? bankDetails;

  const WalletBalanceDto({
    required this.ledgerBalance,
    this.bankDetails,
  });

  factory WalletBalanceDto.fromJson(Map<String, dynamic> json) {
    return WalletBalanceDto(
      ledgerBalance: (json['ledgerBalance'] as num).toDouble(),
      bankDetails: json['bankDetails'] != null
          ? BankDetailsDto.fromJson(json['bankDetails'] as Map<String, dynamic>)
          : null,
    );
  }

  WalletBalance toEntity() {
    return WalletBalance(
      ledgerBalance: ledgerBalance,
      bankDetails: bankDetails?.toEntity(),
    );
  }
}

class SettlementResponseDto {
  final bool success;
  final String reference;
  final String message;
  final double remainingBalance;

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

  SettlementResponse toEntity() {
    return SettlementResponse(
      success: success,
      reference: reference,
      message: message,
      remainingBalance: remainingBalance,
    );
  }
}
