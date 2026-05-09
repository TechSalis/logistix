import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:collection/collection.dart';
import 'package:dispatcher/src/features/more/domain/entities/wallet.dart';
import 'package:dispatcher/src/features/more/presentation/cubit/wallet_cubit.dart';
import 'package:dispatcher/src/features/more/presentation/cubit/wallet_state.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistix_ux/logistix_ux.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final _accountNumberController = TextEditingController();
  Bank? _selectedBank;

  @override
  void initState() {
    super.initState();
    context.read<WalletCubit>().fetchWalletBalance();
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LogistixColors.background,
      appBar: AppBar(
        title: const Text('Wallet & Settlements'),
        backgroundColor: LogistixColors.background,
        elevation: 0,
      ),
      body: BlocConsumer<WalletCubit, WalletState>(
        listener: (context, state) {
          state.whenOrNull(
            error: (message) => context.toast.showToast(
              message,
              type: ToastType.error,
            ),
            settlementSuccess: (_, reference, __) {
              context.toast.showToast(
                'Withdrawal successful! Reference: $reference',
                type: ToastType.success,
              );
            },
            loaded: (balance, banks) {
              if (balance.bankDetails != null) {
                _accountNumberController.text = balance.bankDetails!.number;
                _selectedBank = banks.firstWhereOrNull(
                  (b) => b.bankCode == balance.bankDetails!.code,
                );
              }
            },
          );
        },
        builder: (context, state) {
          return state.maybeWhen(
            loading: () => const Center(child: CircularProgressIndicator()),
            orElse: () {
              final balance = state.maybeWhen(
                loaded: (b, _) => b,
                settlementSuccess: (b, _, __) => b,
                orElse: () => null,
              );

              final banks = state.maybeWhen(
                loaded: (_, banks) => banks,
                settlementSuccess: (_, __, banks) => banks,
                orElse: () => <Bank>[],
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(BootstrapSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBalanceCard(context, balance?.ledgerBalance ?? 0),
                    const SizedBox(height: BootstrapSpacing.xl),
                    Text(
                      'SETTLEMENT ACCOUNT',
                      style: context.textTheme.labelMedium?.bold.copyWith(
                        color: LogistixColors.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: BootstrapSpacing.sm),
                    _buildSettlementForm(context, banks, state.maybeWhen(loading: () => true, orElse: () => false)),
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
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, double balance) {
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
            '₦ ${balance.toStringAsFixed(2)}',
            style: context.textTheme.displaySmall?.bold.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: BootstrapSpacing.lg),
          BootstrapButton(
            label: 'Withdraw Funds',
            icon: Icons.download_rounded,
            onPressed: balance > 0
                ? () {
                    context.read<WalletCubit>().requestSettlement(balance, 'Wallet withdrawal');
                  }
                : null,
            type: BootstrapButtonType.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementForm(BuildContext context, List<Bank> banks, bool isLoading) {
    return BootstrapCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Select the bank where you want your virtual account funds to be settled.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: LogistixColors.textSecondary,
            ),
          ),
          const SizedBox(height: BootstrapSpacing.lg),
          DropdownSearch<Bank>(
            items: (filter, __) => banks
                .where((b) => b.bankName.toLowerCase().contains(filter.toLowerCase()))
                .toList(),
            itemAsString: (bank) => bank.bankName,
            selectedItem: _selectedBank,
            onChanged: (bank) => setState(() => _selectedBank = bank),
            compareFn: (b1, b2) => b1.bankCode == b2.bankCode,
            decoratorProps: DropDownDecoratorProps(
              decoration: InputDecoration(
                labelText: 'Select Bank',
                hintText: 'Search for your bank...',
                prefixIcon: const Icon(Icons.account_balance_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(BootstrapRadii.lg),
                ),
              ),
            ),
            popupProps: const PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: 'Type bank name...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
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
            isLoading: isLoading,
            onPressed: () {
              if (_selectedBank != null && _accountNumberController.text.isNotEmpty) {
                context.read<WalletCubit>().saveBankDetails(
                      _selectedBank!.bankCode,
                      _accountNumberController.text,
                      _selectedBank!.bankName,
                    );
              }
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
            const Icon(
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
