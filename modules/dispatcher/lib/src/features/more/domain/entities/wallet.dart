import 'package:equatable/equatable.dart';

class BankDetails extends Equatable {
  final String code;
  final String number;
  final String name;

  const BankDetails({
    required this.code,
    required this.number,
    required this.name,
  });

  @override
  List<Object?> get props => [code, number, name];
}

class WalletBalance extends Equatable {
  final double ledgerBalance;
  final BankDetails? bankDetails;

  const WalletBalance({
    required this.ledgerBalance,
    this.bankDetails,
  });

  @override
  List<Object?> get props => [ledgerBalance, bankDetails];
}

class SettlementResponse extends Equatable {
  final bool success;
  final String reference;
  final String message;
  final double remainingBalance;

  const SettlementResponse({
    required this.success,
    required this.reference,
    required this.message,
    required this.remainingBalance,
  });

  @override
  List<Object?> get props => [success, reference, message, remainingBalance];
}
