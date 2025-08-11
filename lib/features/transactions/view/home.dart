// ignore_for_file: deprecated_member_use, avoid_print, unrelated_type_equality_checks

import 'dart:developer';

import 'package:financy_ui/features/Transactions/Cubit/transactionCubit.dart';
import 'package:financy_ui/features/Users/Cubit/userCubit.dart';
import 'package:financy_ui/features/Users/Cubit/userState.dart';
import 'package:financy_ui/features/Account/cubit/manageMoneyCubit.dart';
import 'package:financy_ui/features/Users/models/userModels.dart';
import 'package:financy_ui/features/transactions/Cubit/transctionState.dart';
import 'package:financy_ui/features/transactions/models/transactionsModels.dart';
import 'package:financy_ui/features/Account/models/money_source.dart';
import 'package:financy_ui/features/Categories/models/categoriesModels.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/icons.dart';
import '../../../shared/utils/color_utils.dart';
import '../../../shared/utils/mappingIcon.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    print(Hive.box('settings').toMap());
    context.read<TransactionCubit>().fetchTransactionsByDate();
    super.initState();
  }

  String _localText(String Function(AppLocalizations) getter) {
    final appLocal = AppLocalizations.of(context);
    return appLocal != null ? getter(appLocal) : '';
  }

  String _formatAmount(double amount, {bool isUSD = false}) {
    if (isUSD) {
      // Format USD amount with comma separators and 2 decimal places
      final formatter = NumberFormat('#,##0.00', 'en_US');
      return '\$${formatter.format(amount)}';
    } else {
      // Format VND amount with comma separators and no decimal places
      final formatter = NumberFormat('#,###', 'vi_VN');
      return '${formatter.format(amount.toInt())} ₫';
    }
  }

  // Helper method to get category info by name
  Category? _getCategoryByName(String categoryName) {
    // First check in default expense categories
    final expenseCategory = defaultExpenseCategories.firstWhere(
      (category) => category.name == categoryName,
      orElse: () => Category(
        id: '',
        name: '',
        type: '',
        icon: '',
        color: '',
        createdAt: DateTime.now(),
      ),
    );
    
    if (expenseCategory.name.isNotEmpty) {
      return expenseCategory;
    }

    // Then check in default income categories
    final incomeCategory = defaultIncomeCategories.firstWhere(
      (category) => category.name == categoryName,
      orElse: () => Category(
        id: '',
        name: '',
        type: '',
        icon: '',
        color: '',
        createdAt: DateTime.now(),
      ),
    );
    
    if (incomeCategory.name.isNotEmpty) {
      return incomeCategory;
    }

    // If not found in defaults, return null
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        UserModel? user;
        if (state.status == UserStatus.success) {
          user = state.user;
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/profile', arguments: user);
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.colorScheme.background,
                      child: Icon(
                        Icons.person,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _localText((l) => l.hello),
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(user?.name ?? '', style: theme.textTheme.titleLarge),
                    ],
                  ),
                ],
              ),
            ),

            // Chart Section
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.negativeRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        _localText((l) => l.income),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                      SizedBox(width: 20),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.positiveGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        _localText((l) => l.expense),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}M',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textGrey,
                                    fontSize: 10,
                                  ),
                                );
                              },
                              reservedSize: 30,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                // Chỉ hiển thị T1 đến T6
                                if (value >= 1 && value <= 6) {
                                  return Text(
                                    'Month ${value.toInt()}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.textGrey,
                                      fontSize: 10,
                                    ),
                                  );
                                }
                                return SizedBox.shrink(); // Ẩn các tháng khác
                              },
                              interval: 1, // Hiển thị mỗi tháng
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              FlSpot(1, 15),
                              FlSpot(2, 25),
                              FlSpot(3, 18),
                              FlSpot(4, 30),
                              FlSpot(5, 12),
                              FlSpot(6, 28),
                            ],
                            isCurved: true,
                            color: Colors.pink,
                            barWidth: 2,
                            dotData: FlDotData(show: false),
                          ),
                          LineChartBarData(
                            spots: [
                              FlSpot(1, 8),
                              FlSpot(2, 12),
                              FlSpot(3, 15),
                              FlSpot(4, 10),
                              FlSpot(5, 20),
                              FlSpot(6, 18),
                            ],
                            isCurved: true,
                            color: Colors.green,
                            barWidth: 2,
                            dotData: FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Transaction List
            BlocConsumer<TransactionCubit, TransactionState>(
              listener: (context, stateTransaction) {
                if (stateTransaction == TransactionStateStatus.error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        stateTransaction.errorMessage ??
                            'Error fetching transactions',
                      ),
                    ),
                  );
                }
                if (stateTransaction == TransactionStateStatus.success) {
                  context.read<TransactionCubit>().fetchTransactionsByDate();
                }
              },
              builder: (context, stateTransaction) {
                log('Transaction State: ${stateTransaction.status}');
                Map<DateTime, List<Transactionsmodels>>? transactionsList;
                if (stateTransaction.status == TransactionStateStatus.loading) {
                  return Center(child: CircularProgressIndicator());
                }
                if (stateTransaction.status == TransactionStateStatus.loaded) {
                  transactionsList = stateTransaction.transactionsList;
                }
                return Expanded(
                  child:
                      transactionsList?.isEmpty ?? true
                          ? Center(
                            child: Text(
                              'No transactions found',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.black),
                            ),
                          )
                          : ListView.builder(
                            itemCount: transactionsList?.length ?? 0,
                            itemBuilder: (context, index) {
                              final date = transactionsList?.keys.elementAt(
                                index,
                              );
                              final transactions = transactionsList?[date];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDateHeader(
                                    DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(date ?? DateTime.now()),
                                    DateFormat(
                                      'EEEE',
                                    ).format(date ?? DateTime.now()),
                                    context,
                                  ),
                                  ...?transactions?.map((transaction) {
                                    // Get account info to determine currency
                                    final account = context
                                        .read<ManageMoneyCubit>()
                                        .state
                                        .listAccounts
                                        ?.firstWhere(
                                          (acc) =>
                                              acc.id == transaction.accountId,
                                          orElse:
                                              () => MoneySource(
                                                name: 'Unknown',
                                                balance: 0,
                                                currency: CurrencyType.vnd,
                                                isActive: true,
                                              ),
                                        );

                                    // Get category info
                                    final category = _getCategoryByName(transaction.categoriesId);
                                    final categoryIcon = category != null 
                                        ? IconMapping.stringToIcon(category.icon)
                                        : Icons.category;
                                    final categoryColor = category != null 
                                        ? ColorUtils.parseColor(category.color) ?? AppColors.primaryBlue
                                        : AppColors.primaryBlue;

                                    return _buildTransactionItem(
                                      context: context,
                                      icon: categoryIcon,
                                      iconColor: categoryColor,
                                      title: transaction.categoriesId,
                                      subtitle: transaction.note ?? '',
                                      amount: _formatAmount(
                                        transaction.amount,
                                        isUSD:
                                            account?.currency ==
                                            CurrencyType.usd,
                                      ),
                                      isPositive:
                                          transaction.type ==
                                          TransactionType.income,
                                      accountName: account?.name ?? '',
                                      transaction: transaction,
                                    );
                                  }),
                                ],
                              );
                            },
                          ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(String date, String day, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textGrey),
          ),
          Text(
            day,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    required String accountName,
    bool isPositive = false,
    required Transactionsmodels transaction,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        // Navigate to add screen with transaction data for editing
        Navigator.pushNamed(context, '/add', arguments: transaction);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            SizedBox(width: 12),
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
                  if (subtitle.isNotEmpty)
                    Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isPositive ? '+ $amount' : '- $amount',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color:
                        isPositive
                            ? AppColors.positiveGreen
                            : AppColors.negativeRed,
                  ),
                ),
                Text(
                  accountName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textGrey,
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
