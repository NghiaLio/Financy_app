// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:developer';

import 'package:financy_ui/core/constants/colors.dart';
import 'package:financy_ui/core/constants/money_source_icons.dart';
import 'package:financy_ui/features/Account/cubit/manageMoneyCubit.dart';
import 'package:financy_ui/features/Account/cubit/manageMoneyState.dart';
import 'package:financy_ui/features/Account/models/money_source.dart';
import 'package:financy_ui/features/transactions/Cubit/transactionCubit.dart';
import 'package:financy_ui/features/transactions/Cubit/transctionState.dart';
import 'package:financy_ui/features/transactions/models/transactionsModels.dart';
import 'package:financy_ui/shared/utils/localText.dart';
import 'package:financy_ui/shared/utils/mappingIcon.dart';
import 'package:financy_ui/shared/utils/money_source_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  String _formatAmount(num amount) {
    if (amount % 1 == 0) {
      // Là số nguyên
      return amount.toInt().toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => ',',
      );
    } else {
      // Có phần thập phân
      return amount
          .toStringAsFixed(2)
          .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
    }
  }

  List<Transactionsmodels> transactionsList(
    Map<DateTime, List<Transactionsmodels>> transactionsByDate,
  ) {
    List<Transactionsmodels> allTransactions = [];
    transactionsByDate.forEach((date, transactions) {
      allTransactions.addAll(transactions);
    });
    return allTransactions;
  }

  String? currentAccountId;

  void changeAccount(String? newId) {
    if (newId != null) {
      context.read<TransactionCubit>().fetchTransactionsByAccount(newId);
      context.read<ManageMoneyCubit>().setCurrentAccountName(newId);
      setState(() {
        currentAccountId = newId;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Load accounts first, then fetch transactions after accounts are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ManageMoneyCubit>().getAllAccount();

      // After accounts are loaded, get the current account and fetch transactions
      final manageMoneyCubit = context.read<ManageMoneyCubit>();
      final listAccounts = manageMoneyCubit.listAccounts ?? [];

      if (listAccounts.isNotEmpty) {
        // Nếu đã có currentAccountName (tên), tìm id tương ứng
        final currentName = manageMoneyCubit.currentAccountName;
        final found = listAccounts.firstWhere(
          (acc) => acc.name == currentName,
          orElse: () => listAccounts.first,
        );
        setState(() {
          currentAccountId = found.id;
        });

        // Cập nhật TransactionCubit với id tài khoản hiện tại
        if (currentAccountId != null) {
          context.read<TransactionCubit>().fetchTransactionsByAccount(
            currentAccountId!,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No account exists'),
            duration: Duration(seconds: 2),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<TransactionCubit, TransactionState>(
      listener: (context, state) {
        if (state.status == TransactionStateStatus.success) {
          // TransactionCubit đã tự fetch lại từ Hive và emit loaded,
          // chỉ cần reload accounts để cập nhật balance mới nhất
          context.read<ManageMoneyCubit>().getAllAccount();
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            // Balance Card - Redesigned with colorful gradient
            BalanceCard(
              changeAccount: changeAccount,
              currentAccountId: currentAccountId,
            ),
            // Transaction List
            Expanded(
              child: BlocBuilder<TransactionCubit, TransactionState>(
                builder: (context, state) {
                  if (state.status == TransactionStateStatus.loading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state.status == TransactionStateStatus.error) {
                    return Center(child: Text('Error loading transactions'));
                  }
                  if (state.transactionsList.isEmpty) {
                    return Center(
                      child: Text(
                        LocalText.localText(context, (l) => l.noTransactions),
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }
                  final transactionsList = this.transactionsList(
                    state.transactionsList,
                  );
                  return ListView.builder(
                    padding: EdgeInsets.all(12),
                    itemCount: transactionsList.length,
                    itemBuilder: (context, index) {
                      final Transactionsmodels transaction =
                          transactionsList[index];
                      final isIncome =
                          transaction.type == TransactionType.income;
                      final amountStr = _formatAmount(transaction.amount);
                      // Get category by name if needed for default categories
                      final categoryData = IconMapping.getCategoryByName(
                        transaction.categoriesId,
                      );
                      final iconData = IconMapping.stringToIcon(
                        categoryData?.icon ?? 'Home',
                      );
                      final iconColor = Color(
                        int.parse(categoryData?.color ?? '0xFF000000'),
                      );
                      final title = categoryData?.name ?? 'Unknown';
                      return _buildTransactionItem(
                        context,
                        icon: iconData,
                        iconColor: iconColor,
                        title: title,
                        subtitle: transaction.note ?? '',
                        amount: '${isIncome ? '+ ' : '- '}$amountStr VND',
                        isPositive: isIncome,
                        transaction: transaction,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    bool isPositive = false,
    required Transactionsmodels transaction,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(
          context,
          '/add',
          arguments: {'transaction': transaction, 'fromScreen': 'wallet'},
        );
        // Refresh transactions for the current account after returning
        final String? accountIdToRefresh =
            currentAccountId ??
            context.read<ManageMoneyCubit>().listAccounts?.first.id;
        if (accountIdToRefresh != null && accountIdToRefresh.isNotEmpty) {
          context.read<TransactionCubit>().fetchTransactionsByAccount(
            accountIdToRefresh,
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(subtitle, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color:
                        isPositive
                            ? AppColors.positiveGreen
                            : AppColors.negativeRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  LocalText.localText(context, (l) => l.myWallet),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.changeAccount,
    required this.currentAccountId,
  });
  final Function(String?) changeAccount;
  final String? currentAccountId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<ManageMoneyCubit, ManageMoneyState>(
      builder: (context, state) {
        // Luôn ưu tiên lấy listAccounts từ cubit field vì nó luôn được cập nhật đồng bộ
        // state.listAccounts có thể null trong một số trạng thái (loading, error, success không có accounts)
        final cubit = context.read<ManageMoneyCubit>();
        String currentAccountName = cubit.currentAccountName ?? '';
        log(state.status.toString());

        // Ưu tiên: state.listAccounts (nếu có) → cubit.listAccounts (field cache) → []
        List<MoneySource> listAccounts =
            state.listAccounts ?? cubit.listAccounts ?? [];

        MoneySource? currentAccount;
        if (listAccounts.isNotEmpty) {
          if (currentAccountId != null) {
            final found = listAccounts.firstWhere(
              (acc) => acc.id == currentAccountId,
              orElse: () => listAccounts.first,
            );
            currentAccount = found;
          } else {
            currentAccount = listAccounts.first;
          }
          currentAccountName = currentAccount.name;
        }

        // Lấy tổng thu nhập và chi tiêu theo tài khoản hiện tại
        double totalIncome = 0;
        double totalExpense = 0;
        // Lấy transactionsList từ TransactionCubit
        final transactionState = context.watch<TransactionCubit>().state;
        final allTransactions =
            transactionState.transactionsList.values.expand((e) => e).toList();
        final filteredTransactions =
            currentAccountId == null
                ? allTransactions
                : allTransactions
                    .where((t) => t.accountId == currentAccountId)
                    .toList();
        for (final tx in filteredTransactions) {
          if (tx.type == TransactionType.income) {
            totalIncome += tx.amount;
          } else if (tx.type == TransactionType.expense) {
            totalExpense += tx.amount;
          }
        }

        // Determine brand background and logo for current account
        final Color fallbackColor = AppColors.primaryBlue;
        final Color onBrand = Colors.white;
        final String? brandBackground =
            currentAccount != null
                ? MoneySourceBackgrounds.backgroundFor(currentAccount.name)
                : null;
        final String? brandAsset =
            currentAccount != null
                ? MoneySourceImages.assetFor(currentAccount.name)
                : null;

        return Container(
          margin: EdgeInsets.all(12),
          decoration: BoxDecoration(
            image:
                brandBackground != null
                    ? DecorationImage(
                      image: AssetImage(brandBackground),
                      fit: BoxFit.cover,
                    )
                    : null,
            color:
                brandBackground == null ? fallbackColor.withOpacity(0.8) : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.12),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              // Add darker overlay to make text readable on background image
              gradient:
                  brandBackground != null
                      ? LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.black.withOpacity(0.5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                      : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account Selector Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocalText.localText(context, (l) => l.myAccount),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: onBrand,
                              fontWeight: FontWeight.w500,
                              shadows:
                                  brandBackground != null
                                      ? [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.5),
                                          blurRadius: 4,
                                          offset: Offset(0, 1),
                                        ),
                                      ]
                                      : null,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              if (brandAsset != null) ...[
                                ClipOval(
                                  child: Image.asset(
                                    brandAsset,
                                    width: 24,
                                    height: 24,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(width: 8),
                              ],
                              Expanded(
                                child: Text(
                                  currentAccountName.isNotEmpty
                                      ? currentAccountName
                                      : '---',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: onBrand,
                                    fontWeight: FontWeight.bold,
                                    shadows:
                                        brandBackground != null
                                            ? [
                                              Shadow(
                                                color: Colors.black.withOpacity(
                                                  0.7,
                                                ),
                                                blurRadius: 6,
                                                offset: Offset(0, 2),
                                              ),
                                            ]
                                            : null,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          if (currentAccount != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    currentAccount.isActive
                                        ? AppColors.positiveGreen
                                        : AppColors.negativeRed,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                currentAccount.isActive
                                    ? LocalText.localText(
                                      context,
                                      (l) => l.active,
                                    )
                                    : LocalText.localText(
                                      context,
                                      (l) => l.inactive,
                                    ),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: onBrand,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Brand logo and Account Dropdown Button
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                brandBackground != null
                                    ? Colors.white.withOpacity(0.2)
                                    : onBrand.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  brandBackground != null
                                      ? Colors.white.withOpacity(0.4)
                                      : onBrand.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow:
                                brandBackground != null
                                    ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ]
                                    : null,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value:
                                  currentAccountId ??
                                  (listAccounts.isNotEmpty
                                      ? listAccounts.first.id
                                      : null),
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color: onBrand,
                                size: 16,
                              ),
                              selectedItemBuilder: (BuildContext context) {
                                return listAccounts.map((e) {
                                  return Center(
                                    child: Text(
                                      e.name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        shadows:
                                            brandBackground != null
                                                ? [
                                                  Shadow(
                                                    color: Colors.black
                                                        .withOpacity(0.5),
                                                    blurRadius: 3,
                                                    offset: Offset(0, 1),
                                                  ),
                                                ]
                                                : null,
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: onBrand,
                                fontWeight: FontWeight.w600,
                              ),
                              dropdownColor: theme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              items:
                                  listAccounts
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e.id,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (MoneySourceImages.assetFor(
                                                    e.name,
                                                  ) !=
                                                  null)
                                                ClipOval(
                                                  child: Image.asset(
                                                    MoneySourceImages.assetFor(
                                                      e.name,
                                                    )!,
                                                    width: 18,
                                                    height: 18,
                                                    fit: BoxFit.contain,
                                                  ),
                                                )
                                              else
                                                Icon(
                                                  MoneySourceIconColorMapper.iconFor(
                                                    e.type.toString(),
                                                  ),
                                                  color:
                                                      theme
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color,
                                                  size: 18,
                                                ),
                                              SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  e.name,
                                                  style:
                                                      theme
                                                          .textTheme
                                                          .bodyMedium,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: changeAccount,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Income and Expense Row
                Row(
                  children: [
                    // Income Section
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              brandBackground != null
                                  ? Colors.white.withOpacity(0.15)
                                  : AppColors.positiveGreen.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                brandBackground != null
                                    ? Colors.white.withOpacity(0.3)
                                    : AppColors.positiveGreen.withOpacity(0.15),
                            width: 1.5,
                          ),
                          boxShadow:
                              brandBackground != null
                                  ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color:
                                        brandBackground != null
                                            ? Colors.white.withOpacity(0.3)
                                            : AppColors.positiveGreen
                                                .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.trending_up,
                                    color:
                                        brandBackground != null
                                            ? Colors.white
                                            : AppColors.positiveGreen,
                                    size: 12,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    LocalText.localText(
                                      context,
                                      (l) => l.income,
                                    ),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: onBrand,
                                      fontWeight: FontWeight.w600,
                                      shadows:
                                          brandBackground != null
                                              ? [
                                                Shadow(
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                  blurRadius: 3,
                                                  offset: Offset(0, 1),
                                                ),
                                              ]
                                              : null,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Text(
                              '+${totalIncome.toStringAsFixed(0)} VND',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: onBrand,
                                fontWeight: FontWeight.bold,
                                shadows:
                                    brandBackground != null
                                        ? [
                                          Shadow(
                                            color: Colors.black.withOpacity(
                                              0.6,
                                            ),
                                            blurRadius: 4,
                                            offset: Offset(0, 1),
                                          ),
                                        ]
                                        : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    // Expense Section
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              brandBackground != null
                                  ? Colors.white.withOpacity(0.15)
                                  : AppColors.negativeRed.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                brandBackground != null
                                    ? Colors.white.withOpacity(0.3)
                                    : AppColors.negativeRed.withOpacity(0.15),
                            width: 1.5,
                          ),
                          boxShadow:
                              brandBackground != null
                                  ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color:
                                        brandBackground != null
                                            ? Colors.white.withOpacity(0.3)
                                            : AppColors.negativeRed.withOpacity(
                                              0.2,
                                            ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.trending_down,
                                    color:
                                        brandBackground != null
                                            ? Colors.white
                                            : AppColors.negativeRed,
                                    size: 12,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    LocalText.localText(
                                      context,
                                      (l) => l.expense,
                                    ),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: onBrand,
                                      fontWeight: FontWeight.w600,
                                      shadows:
                                          brandBackground != null
                                              ? [
                                                Shadow(
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                  blurRadius: 3,
                                                  offset: Offset(0, 1),
                                                ),
                                              ]
                                              : null,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Text(
                              '-${totalExpense.toStringAsFixed(0)} VND',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: onBrand,
                                fontWeight: FontWeight.bold,
                                shadows:
                                    brandBackground != null
                                        ? [
                                          Shadow(
                                            color: Colors.black.withOpacity(
                                              0.6,
                                            ),
                                            blurRadius: 4,
                                            offset: Offset(0, 1),
                                          ),
                                        ]
                                        : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
