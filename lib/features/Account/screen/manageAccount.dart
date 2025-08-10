// ignore_for_file: deprecated_member_use, file_names

import 'dart:developer';

import 'package:financy_ui/features/Account/cubit/manageMoneyCubit.dart';
import 'package:financy_ui/features/Account/cubit/manageMoneyState.dart';
import 'package:financy_ui/shared/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/constants/colors.dart';
import '../models/money_source.dart';
import 'package:financy_ui/shared/utils/money_source_utils.dart';

class AccountMoneyScreen extends StatefulWidget {
  const AccountMoneyScreen({super.key});

  @override
  State<AccountMoneyScreen> createState() => _AccountMoneyScreenState();
}

class _AccountMoneyScreenState extends State<AccountMoneyScreen> {
  bool isBalanceVisible = true;
  bool isTotalInUSD = true; // Switch between USD and VND for total balance

  List<MoneySource> get moneySources {
    final state = context.read<ManageMoneyCubit>().state;
    return state.listAccounts ?? [];
  }

  double get totalBalance => moneySources
      .where((source) => source.isActive == true)
      .fold(0.0, (sum, source) => sum + source.balance);

  // Get total balance in USD (convert VND to USD)
  double get totalBalanceInUSD {
    final exchangeRate = double.parse(
      dotenv.env['EXCHANGE_RATE_USD_TO_VND'] ?? '24500',
    );
    return moneySources.where((source) => source.isActive == true).fold(0.0, (
      sum,
      source,
    ) {
      if (source.currency == CurrencyType.vnd) {
        return sum + (source.balance / exchangeRate);
      } else {
        return sum + source.balance;
      }
    });
  }

  // Get total balance in VND (convert USD to VND)
  double get totalBalanceInVND {
    final exchangeRate = double.parse(
      dotenv.env['EXCHANGE_RATE_USD_TO_VND'] ?? '24500',
    );
    return moneySources.where((source) => source.isActive == true).fold(0.0, (
      sum,
      source,
    ) {
      if (source.currency == CurrencyType.usd) {
        return sum + (source.balance * exchangeRate);
      } else {
        return sum + source.balance;
      }
    });
  }

  // Format currency with comma separators and appropriate decimal places
  String _formatCurrency(double amount, {bool isUSD = false}) {
    if (isUSD) {
      // USD: 2 decimal places
      final formatted = amount.toStringAsFixed(2);
      final parts = formatted.split('.');
      final integerPart = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match match) => '${match[1]},',
      );
      return '$integerPart.${parts[1]}';
    } else {
      // VND: no decimal places
      return amount.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match match) => '${match[1]},',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    // AppLocalizations.of(context) will never be null in a properly configured app
    final localizations = AppLocalizations.of(context);
    return BlocConsumer<ManageMoneyCubit, ManageMoneyState>(
      listener: (context, state) {
        if (state.status == ManageMoneyStatus.success) {
          context.read<ManageMoneyCubit>().getAllAccount();
        }
      },
      builder: (context, state) {
        log(state.status.toString());
        if (state.status == ManageMoneyStatus.loading) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (state.status == ManageMoneyStatus.error) {
          // Show error dialog and pop after user closes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (context) => AlertDialog(
                    title: Text(
                      AppLocalizations.of(context)?.notification ??
                          'Notification',
                    ),
                    content: Text(state.message ?? 'Unknown error'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          Navigator.of(context).pop(); // Pop screen
                        },
                        child: Text(
                          AppLocalizations.of(context)?.close ?? 'Close',
                        ),
                      ),
                    ],
                  ),
            );
          });
          return const SizedBox.shrink();
        } else {
          return Scaffold(
            backgroundColor: colorScheme.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.onBackground),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                localizations?.moneySources ?? 'Money Sources',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onBackground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                IconButton(
                  onPressed:
                      () => Navigator.pushNamed(context, '/addMoneySource'),
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                // Total Balance Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primaryBlue, AppColors.accentPink],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            localizations?.totalMoney ?? 'Total Money',
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: [
                              // Custom Currency Switch
                              _CurrencySwitch(
                                isUSD: isTotalInUSD,
                                onToggle: () {
                                  setState(() {
                                    isTotalInUSD = !isTotalInUSD;
                                  });
                                },
                              ),
                              const SizedBox(width: 12),
                              // Visibility toggle
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    isBalanceVisible = !isBalanceVisible;
                                  });
                                },
                                icon: Icon(
                                  isBalanceVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isBalanceVisible
                            ? '${isTotalInUSD ? '\$' : '₫'}${_formatCurrency(isTotalInUSD ? totalBalanceInUSD : totalBalanceInVND, isUSD: isTotalInUSD)}'
                            : '••••••',
                        style: textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localizations?.sourcesAvailable(moneySources.length) ??
                            '${moneySources.length} sources available',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Money Sources List
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            localizations?.moneySources ?? 'Money Sources',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              await context
                                  .read<ManageMoneyCubit>()
                                  .getAllAccount();
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: moneySources.length,
                              itemBuilder: (context, index) {
                                final source = moneySources[index];
                                return _MoneySourceTile(
                                  source: source,
                                  isBalanceVisible: isBalanceVisible,
                                  onTap:
                                      () => Navigator.pushNamed(
                                        context,
                                        '/accountDetail',
                                        arguments: source,
                                      ),

                                  onDelete: () => _deleteSource(index),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },

    );
  }

  @override
  void initState() {
    super.initState();
    // Load initial data if needed
    context.read<ManageMoneyCubit>().getAllAccount();
  }

  void _deleteSource(int index) {
    // AppLocalizations.of(context) will never be null in a properly configured app
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localizations?.deleteSource ?? 'Delete Source'),
            content: Text(
              localizations?.deleteSourceConfirm(moneySources[index].name) ??
                  'Are you sure you want to delete ${moneySources[index].name}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(localizations?.cancel ?? 'Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<ManageMoneyCubit>().deleteAccount(
                    moneySources[index],
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.negativeRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  localizations?.delete ?? 'Delete',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}

class _CurrencySwitch extends StatelessWidget {
  final bool isUSD;
  final VoidCallback onToggle;

  const _CurrencySwitch({required this.isUSD, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 80,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Stack(
          children: [
            // Background indicator
            Positioned(
              left: isUSD ? 2 : 40,
              top: 2,
              child: Container(
                width: 36,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            // Currency options
            Row(
              children: [
                // USD Option
                Expanded(
                  child: Container(
                    height: 32,
                    alignment: Alignment.center,
                    child: Text(
                      '\$',
                      style: TextStyle(
                        color: isUSD ? AppColors.primaryBlue : Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // VND Option
                Expanded(
                  child: Container(
                    height: 32,
                    alignment: Alignment.center,
                    child: Text(
                      '₫',
                      style: TextStyle(
                        color: !isUSD ? AppColors.primaryBlue : Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MoneySourceTile extends StatelessWidget {
  final MoneySource source;
  final bool isBalanceVisible;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _MoneySourceTile({
    required this.source,
    required this.isBalanceVisible,
    required this.onTap,
    required this.onDelete,
  });

  // Format currency with comma separators and appropriate decimal places
  String _formatCurrency(double amount, {bool isUSD = false}) {
    if (isUSD) {
      // USD: 2 decimal places
      final formatted = amount.toStringAsFixed(2);
      final parts = formatted.split('.');
      final integerPart = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match match) => '${match[1]},',
      );
      return '$integerPart.${parts[1]}';
    } else {
      // VND: no decimal places
      return amount.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match match) => '${match[1]},',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    // AppLocalizations.of(context) will never be null in a properly configured app
    final localizations = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (ColorUtils.parseColor(source.color) ??
                    AppColors.primaryBlue)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            MoneySourceIconColorMapper.iconFor(
              source.type?.toString().split('.').last ?? '',
            ),
            color: ColorUtils.parseColor(source.color) ?? AppColors.primaryBlue,
            size: 20,
          ),
        ),
        title: Text(
          source.name,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isBalanceVisible
                  ? '${source.currency == CurrencyType.vnd ? '₫' : '\$'}${_formatCurrency(source.balance, isUSD: source.currency == CurrencyType.usd)}'
                  : '••••••',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.positiveGreen,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              source.isActive == true
                  ? localizations?.active ?? 'Active'
                  : localizations?.inactive ?? 'Inactive',
              style: textTheme.bodySmall?.copyWith(
                color:
                    source.isActive == true
                        ? AppColors.positiveGreen
                        : AppColors.negativeRed,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            onDelete();
          },
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: colorScheme.error),
                      const SizedBox(width: 8),
                      Text(
                        localizations?.delete ?? 'Delete',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
        ),
        onTap: onTap,
      ),
    );
  }
}
