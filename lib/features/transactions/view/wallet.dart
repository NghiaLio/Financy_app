// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:developer';

import 'package:financy_ui/core/constants/colors.dart';
import 'package:financy_ui/features/Account/cubit/manageMoneyCubit.dart';
import 'package:financy_ui/features/Account/cubit/manageMoneyState.dart';
import 'package:financy_ui/features/Account/models/money_source.dart';
import 'package:financy_ui/features/Transactions/Cubit/transactionCubit.dart';
import 'package:financy_ui/features/Transactions/Cubit/transctionState.dart';
import 'package:financy_ui/features/Transactions/models/transactionsModels.dart';
import 'package:financy_ui/shared/utils/localText.dart';
import 'package:financy_ui/shared/utils/money_source_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
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
    // Lấy id tài khoản hiện tại từ ManageMoneyCubit (nếu có)
    final manageMoneyCubit = context.read<ManageMoneyCubit>();
    final listAccounts = manageMoneyCubit.listAccounts ?? [];
    if (listAccounts.isNotEmpty) {
      // Nếu đã có currentAccountName (tên), tìm id tương ứng
      final currentName = manageMoneyCubit.currentAccountName;
      final found = listAccounts.firstWhere(
        (acc) => acc.name == currentName,
        orElse: () => listAccounts.first,
      );
      currentAccountId = found.id;
      // Cập nhật TransactionCubit với id tài khoản hiện tại
      context.read<TransactionCubit>().fetchTransactionsByAccount(
        currentAccountId ?? listAccounts.first.id ?? '',
      );
    } else {
      currentAccountId = null;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentAccountId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No account exists'),
            duration: Duration(seconds: 2),
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
          log('hllo');
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
                      return _buildTransactionItem(
                        context,
                        icon: Icons.money,
                        iconColor: AppColors.blue,
                        title: transaction.categoriesId,
                        subtitle: 'Description of transaction $index',
                        amount:
                            transaction.type == TransactionType.income
                                ? '+${transaction.amount} VND'
                                : '-${transaction.amount} VND',
                        isPositive: transaction.type == TransactionType.income,
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
        final String? accountIdToRefresh = currentAccountId ??
            context.read<ManageMoneyCubit>().listAccounts?.first.id;
        if (accountIdToRefresh != null && accountIdToRefresh.isNotEmpty) {
          context
              .read<TransactionCubit>()
              .fetchTransactionsByAccount(accountIdToRefresh);
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
                            : theme.textTheme.bodyLarge?.color,
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
        // Lấy tên tài khoản hiện tại dựa vào id
        String currentAccountName = '';
        log(state.status.toString());
        List<MoneySource>? listAccounts;
        if (state.status == ManageMoneyStatus.loaded) {
          listAccounts = state.listAccounts;
          currentAccountName =
              context.read<ManageMoneyCubit>().currentAccountName ?? '';
        } else {
          listAccounts = [];
        }

        if (currentAccountId != null &&
            listAccounts != null &&
            listAccounts.isNotEmpty) {
          final found = listAccounts.firstWhere(
            (acc) => acc.id == currentAccountId,
            orElse: () => listAccounts!.first,
          );
          currentAccountName = found.name;
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

        return Container(
          margin: EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryBlue, AppColors.teal, AppColors.blue],
            ),
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
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.cardColor.withOpacity(0.1),
                  theme.cardColor.withOpacity(0.05),
                ],
              ),
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
                              color: AppColors.textDark.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            currentAccountName.isNotEmpty
                                ? currentAccountName
                                : '---',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Account Dropdown Button
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.cardColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.cardColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value:
                              currentAccountId ??
                              (listAccounts != null && listAccounts.isNotEmpty
                                  ? listAccounts.first.id
                                  : null),
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.textDark,
                            size: 16,
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                          dropdownColor: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          items:
                              listAccounts != null
                                  ? listAccounts
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e.id,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                MoneySourceIconColorMapper.iconFor(
                                                  e.type.toString(),
                                                ),
                                                color: AppColors.blue,
                                                size: 18,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                e.name,
                                                style:
                                                    theme.textTheme.bodyMedium,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList()
                                  : [],
                          onChanged: changeAccount,
                        ),
                      ),
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
                          color: AppColors.positiveGreen.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.positiveGreen.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.positiveGreen.withOpacity(
                                      0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.trending_up,
                                    color: AppColors.positiveGreen,
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
                                      color: AppColors.positiveGreen,
                                      fontWeight: FontWeight.w500,
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
                                color: AppColors.positiveGreen,
                                fontWeight: FontWeight.bold,
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
                          color: AppColors.negativeRed.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.negativeRed.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.negativeRed.withOpacity(
                                      0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.trending_down,
                                    color: AppColors.negativeRed,
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
                                      color: AppColors.negativeRed,
                                      fontWeight: FontWeight.w500,
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
                                color: AppColors.negativeRed,
                                fontWeight: FontWeight.bold,
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
