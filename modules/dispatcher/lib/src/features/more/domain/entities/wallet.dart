import 'package:equatable/equatable.dart';

class BankDetails extends Equatable {
  const BankDetails({
    required this.code,
    required this.number,
    required this.name,
  });

  final String code;
  final String number;
  final String name;

  @override
  List<Object?> get props => [code, number, name];
}

class WalletBalance extends Equatable {
  const WalletBalance({
    required this.ledgerBalance,
    this.bankDetails,
  });

  final double ledgerBalance;
  final BankDetails? bankDetails;

  @override
  List<Object?> get props => [ledgerBalance, bankDetails];
}

class SettlementResponse extends Equatable {
  const SettlementResponse({
    required this.success,
    required this.reference,
    required this.message,
    required this.remainingBalance,
  });

  final bool success;
  final String reference;
  final String message;
  final double remainingBalance;

  @override
  List<Object?> get props => [success, reference, message, remainingBalance];
}

class Bank extends Equatable {
  const Bank({
    required this.bankCode,
    required this.bankName,
  });

  final String bankCode;
  final String bankName;

  @override
  List<Object?> get props => [bankCode, bankName];
}
