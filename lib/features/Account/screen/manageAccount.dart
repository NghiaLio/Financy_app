// ignore_for_file: deprecated_member_use, file_names

import 'dart:developer';

import 'package:financy_ui/features/Account/cubit/manageMoneyCubit.dart';
import 'package:financy_ui/features/Account/cubit/manageMoneyState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financy_ui/l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/constants/colors.dart';
import '../models/money_source.dart';
import 'package:financy_ui/shared/utils/money_source_utils.dart';
import 'package:financy_ui/core/constants/money_source_icons.dart';

class AccountMoneyScreen extends StatefulWidget {
  const AccountMoneyScreen({super.key});

  @override
  State<AccountMoneyScreen> createState() => _AccountMoneyScreenState();
}

class _AccountMoneyScreenState extends State<AccountMoneyScreen> {
  bool isBalanceVisible = false;
  bool isTotalInUSD = false; // Switch between USD and VND for total balance

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
          log(state.listAccounts.toString());
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
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
                // Total Balance Card with Gradient
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withBlue(
                          (colorScheme.primary.blue * 0.8).toInt(),
                        ),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localizations?.totalMoney ?? 'Total Money',
                                style: textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onPrimary.withOpacity(0.9),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                isBalanceVisible
                                    ? '${isTotalInUSD ? '\$' : '₫'}${_formatCurrency(isTotalInUSD ? totalBalanceInUSD : totalBalanceInVND, isUSD: isTotalInUSD)}'
                                    : '••••••',
                                style: textTheme.displaySmall?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 36,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          Column(
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
                              const SizedBox(height: 8),
                              // Visibility toggle
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isBalanceVisible = !isBalanceVisible;
                                    });
                                  },
                                  icon: Icon(
                                    isBalanceVisible
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded,
                                    color: colorScheme.onPrimary,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.account_balance_wallet_rounded,
                              color: colorScheme.onPrimary.withOpacity(0.9),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              localizations?.sourcesAvailable(
                                    moneySources.length,
                                  ) ??
                                  '${moneySources.length} sources available',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onPrimary.withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                localizations?.moneySources ?? 'Money Sources',
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            color: colorScheme.primary,
                            onRefresh: () async {
                              await context
                                  .read<ManageMoneyCubit>()
                                  .getAllAccount();
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
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
        width: 88,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background indicator with animation
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: isUSD ? 3 : 45,
              top: 3,
              child: Container(
                width: 40,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),

            // Currency options
            Row(
              children: [
                // USD Option
                Expanded(
                  child: Container(
                    height: 38,
                    alignment: Alignment.center,
                    child: Text(
                      '\$',
                      style: TextStyle(
                        color: isUSD ? AppColors.primaryBlue : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // VND Option
                Expanded(
                  child: Container(
                    height: 38,
                    alignment: Alignment.center,
                    child: Text(
                      '₫',
                      style: TextStyle(
                        color: !isUSD ? AppColors.primaryBlue : Colors.white,
                        fontSize: 18,
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Container with Image Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child:
                      MoneySourceImages.assetFor(source.name) != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Image.asset(
                                MoneySourceImages.assetFor(source.name)!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                          : Icon(
                            MoneySourceIconColorMapper.iconFor(
                              source.type?.toString().split('.').last ?? '',
                            ),
                            color: colorScheme.primary,
                            size: 28,
                          ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              source.name,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  source.isActive == true
                                      ? AppColors.positiveGreen.withOpacity(
                                        0.15,
                                      )
                                      : AppColors.negativeRed.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              source.isActive == true
                                  ? localizations?.active ?? 'Active'
                                  : localizations?.inactive ?? 'Inactive',
                              style: textTheme.bodySmall?.copyWith(
                                color:
                                    source.isActive == true
                                        ? AppColors.positiveGreen
                                        : AppColors.negativeRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isBalanceVisible
                                  ? '${source.currency == CurrencyType.vnd ? '₫' : '\$'}${_formatCurrency(source.balance, isUSD: source.currency == CurrencyType.usd)}'
                                  : '••••••',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: AppColors.positiveGreen,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          // Menu Button
                          Container(
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: PopupMenuButton<String>(
                              onSelected: (value) {
                                onDelete();
                              },
                              icon: Icon(
                                Icons.more_horiz_rounded,
                                color: colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              itemBuilder:
                                  (context) => [
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete_outline_rounded,
                                            size: 20,
                                            color: colorScheme.error,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            localizations?.delete ?? 'Delete',
                                            style: textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: colorScheme.error,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
