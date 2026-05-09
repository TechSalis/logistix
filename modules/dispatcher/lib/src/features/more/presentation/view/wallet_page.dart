import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final _bankCodeController = TextEditingController();
  final _accountNumberController = TextEditingController();

  @override
  void dispose() {
    _bankCodeController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LogistixColors.background,
      appBar: AppBar(title: const Text('Wallet & Settlements')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(BootstrapSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBalanceCard(context),
            const SizedBox(height: BootstrapSpacing.xl),
            Text(
              'SETTLEMENT ACCOUNT',
              style: context.textTheme.labelMedium?.bold.copyWith(
                color: LogistixColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: BootstrapSpacing.sm),
            _buildSettlementForm(context),
            const SizedBox(height: BootstrapSpacing.xl),
            Text(
              'RECENT PAYOUTS',
              style: context.textTheme.labelMedium?.bold.copyWith(
                color: LogistixColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: BootstrapSpacing.sm),
            _buildEmptyState(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BootstrapSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            LogistixColors.primary,
            LogistixColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(BootstrapRadii.xl),
        boxShadow: [
          BoxShadow(
            color: LogistixColors.primary.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Ledger Balance',
            style: context.textTheme.titleSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: BootstrapSpacing.xs),
          Text(
            '₦ 0.00',
            style: context.textTheme.displaySmall?.bold.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: BootstrapSpacing.lg),
          BootstrapButton(
            label: 'Withdraw Funds',
            icon: Icons.download_rounded,
            onPressed: () {
              // TODO: Implement withdrawal modal
            },
            type: BootstrapButtonType.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementForm(BuildContext context) {
    return BootstrapCard(
      padding: const EdgeInsets.all(BootstrapSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enter the bank details where you want your virtual account funds to be settled.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: LogistixColors.textSecondary,
            ),
          ),
          const SizedBox(height: BootstrapSpacing.lg),
          BootstrapTextField(
            label: 'Bank Name / Code',
            hintText: 'e.g. Providus Bank',
            controller: _bankCodeController,
            icon: Icons.account_balance_outlined,
          ),
          const SizedBox(height: BootstrapSpacing.md),
          BootstrapTextField(
            label: 'Account Number',
            hintText: '10 digit account number',
            controller: _accountNumberController,
            keyboardType: TextInputType.number,
            icon: Icons.numbers_rounded,
          ),
          const SizedBox(height: BootstrapSpacing.lg),
          BootstrapButton(
            label: 'Save Account Details',
            onPressed: () {
              // TODO: Implement save settlement details
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return BootstrapCard(
      padding: const EdgeInsets.all(BootstrapSpacing.xl),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: LogistixColors.textTertiary,
            ),
            const SizedBox(height: BootstrapSpacing.md),
            Text(
              'No payouts yet',
              style: context.textTheme.titleMedium?.bold,
            ),
            const SizedBox(height: BootstrapSpacing.xs),
            Text(
              'When you withdraw funds to your settlement account, they will appear here.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: LogistixColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
