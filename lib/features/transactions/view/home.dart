// ignore_for_file: deprecated_member_use, avoid_print, unrelated_type_equality_checks

import 'dart:developer';

import 'package:financy_ui/features/Transactions/Cubit/transactionCubit.dart';
import 'package:financy_ui/features/Users/Cubit/userCubit.dart';
import 'package:financy_ui/features/Users/Cubit/userState.dart';
import 'package:financy_ui/features/Account/cubit/manageMoneyCubit.dart';
import 'package:financy_ui/features/Users/models/userModels.dart';
import 'package:financy_ui/features/Transactions/Cubit/transctionState.dart';
import 'package:financy_ui/features/Transactions/models/transactionsModels.dart';
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

  // Calculate monthly data for chart (full 12 months)
  Map<int, Map<String, double>> _calculateMonthlyData(Map<DateTime, List<Transactionsmodels>> transactions) {
    final monthlyData = <int, Map<String, double>>{};
    final currentYear = DateTime.now().year;
    
    // Initialize 12 months data
    for (int month = 1; month <= 12; month++) {
      monthlyData[month] = {'income': 0.0, 'expense': 0.0};
    }
    
    transactions.forEach((date, txList) {
      if (date.year == currentYear) {
        for (var tx in txList) {
          final month = date.month;
          if (tx.type == TransactionType.income) {
            monthlyData[month]!['income'] = (monthlyData[month]!['income']! + tx.amount.toDouble());
          } else if (tx.type == TransactionType.expense) {
            monthlyData[month]!['expense'] = (monthlyData[month]!['expense']! + tx.amount.toDouble());
          }
        }
      }
    });
    
    // Use real data only - no sample data
    
    return monthlyData;
  }

  // Fixed unit conversion to tens of thousands (chục nghìn)
  Map<String, dynamic> _getSmartUnit(double maxAmount) {
    // Always use tens of thousands (10K) as the unit
    return {'divisor': 10000.0, 'unit': '0K', 'unitName': 'chục nghìn'};
  }

  // Convert amount based on smart unit
  double _convertAmount(double amount, double divisor) {
    return amount / divisor;
  }

  // Get max amount to determine unit
  double _getMaxAmount(Map<int, Map<String, double>> monthlyData) {
    double maxValue = 0;
    for (var data in monthlyData.values) {
      final income = data['income']!;
      final expense = data['expense']!;
      if (income > maxValue) maxValue = income;
      if (expense > maxValue) maxValue = expense;
    }
    return maxValue;
  }

  // Calculate max Y value for chart with smart scaling (in tens of thousands)
  double _getMaxY(Map<int, Map<String, double>> monthlyData, double divisor) {
    double maxValue = 0;
    for (var data in monthlyData.values) {
      final income = _convertAmount(data['income']!, divisor);
      final expense = _convertAmount(data['expense']!, divisor);
      if (income > maxValue) maxValue = income;
      if (expense > maxValue) maxValue = expense;
    }
    
    // If no data, set minimum scale
    if (maxValue == 0) {
      return 10.0; // 10 x 10K = 100K minimum scale
    }
    
    // Smart interval for tens of thousands unit
    double interval;
    if (maxValue <= 5) {
      interval = 1.0;  // 1, 2, 3, 4, 5 (10K, 20K, 30K, 40K, 50K)
    } else if (maxValue <= 20) {
      interval = 5.0;  // 5, 10, 15, 20 (50K, 100K, 150K, 200K)
    } else if (maxValue <= 50) {
      interval = 10.0; // 10, 20, 30, 40, 50 (100K, 200K, 300K, 400K, 500K)
    } else {
      interval = 20.0; // 20, 40, 60, 80, 100 (200K, 400K, 600K, 800K, 1M)
    }
    
    // Add padding and round up to nearest interval
    final paddedMax = maxValue * 1.2;
    return ((paddedMax / interval).ceil() * interval).toDouble().clamp(interval, double.infinity);
  }

  // Format amount for tooltip display in original VND
  String _formatTooltipAmount(double amount) {
    if (amount >= 1000000000.0) {
      return '${(amount / 1000000000.0).toStringAsFixed(1)} tỷ ₫';
    } else if (amount >= 1000000.0) {
      return '${(amount / 1000000.0).toStringAsFixed(1)} triệu ₫';
    } else if (amount >= 1000.0) {
      return '${(amount / 1000.0).toStringAsFixed(0)} nghìn ₫';
    } else {
      return '${amount.toStringAsFixed(0)} ₫';
    }
  }

  // Calculate chart width for 12 months
  double _calculateChartWidth() {
    const double monthWidth = 60.0; // Width per month
    const double leftPadding = 60.0; // Increased for left titles (40 reservedSize + 20 padding)
    const double rightPadding = 20.0;
    
    return leftPadding + rightPadding + (12 * monthWidth);
  }

  // Check if chart needs scrolling
  bool _needsScroll(double screenWidth) {
    final chartWidth = _calculateChartWidth();
    return chartWidth > screenWidth - 32; // 32 = container margin
  }

  // Scroll to current month (similar to spending.dart logic)
  void _scrollToCurrentMonth(ScrollController scrollController) {
    if (!scrollController.hasClients) return;
    
    final currentMonth = DateTime.now().month;
    
    // Calculate scroll parameters similar to spending.dart
    final screenWidth = MediaQuery.of(context).size.width - 64; // 64 = container margins
    final monthWidth = 60.0; // Width per month
    final visibleMonths = (screenWidth / monthWidth).floor().clamp(1, 12);
    final centerOffset = (visibleMonths / 2).floor();
    
    // Calculate chart dimensions
    final chartWidth = _calculateChartWidth();
    final maxScrollOffset = (chartWidth - screenWidth).clamp(0.0, double.infinity);
    
    if (maxScrollOffset <= 0) return; // No need to scroll if chart fits screen
    
    // Calculate target scroll position to center current month
    final maxTargetIndex = (12 - visibleMonths).clamp(0, 11);
    final targetIndex = (currentMonth - centerOffset - 1).clamp(0, maxTargetIndex);
    final scrollOffset = (targetIndex * monthWidth).clamp(0.0, maxScrollOffset);
    
    if (scrollOffset > 0 && scrollOffset.isFinite) {
      scrollController.animateTo(
        scrollOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // Build scrollable chart for 12 months
  Widget _buildScrollableChart(
    List<FlSpot> incomeSpots, 
    List<FlSpot> expenseSpots, 
    Map<int, Map<String, double>> monthlyData,
    double divisor,
    ThemeData theme
  ) {
    final ScrollController scrollController = ScrollController();
    
    // Auto scroll to current month (similar to spending.dart logic)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentMonth(scrollController);
    });

    return Stack(
      children: [
        SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: _calculateChartWidth(),
            child: _buildLineChart(incomeSpots, expenseSpots, monthlyData, divisor, theme),
          ),
        ),
        // Scroll indicators - positioned after left titles to avoid covering units
        Positioned(
          left: 55, // Start after left titles area (reservedSize: 40 + padding)
          top: 0,
          bottom: 20,
          child: Container(
            width: 12,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.cardColor,
                  theme.cardColor.withOpacity(0),
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 20,
          child: Container(
            width: 12, // Match left indicator width
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.cardColor.withOpacity(0),
                  theme.cardColor,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
        // "Current Month" indicator button
        Positioned(
          right: 25,
          top: 10,
          child: GestureDetector(
            onTap: () => _scrollToCurrentMonth(scrollController),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.4),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.today,
                    size: 12,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tháng này',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Build static chart
  Widget _buildStaticChart(
    List<FlSpot> incomeSpots, 
    List<FlSpot> expenseSpots, 
    Map<int, Map<String, double>> monthlyData,
    double divisor,
    ThemeData theme
  ) {
    return _buildLineChart(incomeSpots, expenseSpots, monthlyData, divisor, theme);
  }

  // Build the actual LineChart widget
  Widget _buildLineChart(
    List<FlSpot> incomeSpots, 
    List<FlSpot> expenseSpots, 
    Map<int, Map<String, double>> monthlyData,
    double divisor,
    ThemeData theme
  ) {
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => theme.colorScheme.surface,
            tooltipBorder: BorderSide(
              color: theme.dividerColor,
              width: 1,
            ),
            tooltipPadding: EdgeInsets.all(8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                final isIncome = touchedSpot.barIndex == 0;
                final month = touchedSpot.x.toInt();
                final monthNames = ['', 'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9', 'T10', 'T11', 'T12'];
                final displayAmount = touchedSpot.y * divisor; // Convert back to original amount
                
                return LineTooltipItem(
                  '${monthNames[month]}\n${isIncome ? 'Thu nhập' : 'Chi tiêu'}: ${_formatTooltipAmount(displayAmount)}',
                  TextStyle(
                    color: isIncome ? AppColors.positiveGreen : AppColors.negativeRed,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _getMaxY(monthlyData, divisor) / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.textGrey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${(value * 10).toInt()}K',  // Convert back to display format
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textGrey,
                    fontSize: 10,
                  ),
                );
              },
              reservedSize: 40,
              interval: _getMaxY(monthlyData, divisor) / 5,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final months = ['', 'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9', 'T10', 'T11', 'T12'];
                if (value >= 1 && value <= 12) {
                  return Text(
                    months[value.toInt()],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textGrey,
                      fontSize: 10,
                    ),
                  );
                }
                return SizedBox.shrink();
              },
              interval: 1,
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
          // Income line (green)
          LineChartBarData(
            spots: incomeSpots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColors.positiveGreen,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: AppColors.positiveGreen,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.positiveGreen.withOpacity(0.3),
                  AppColors.positiveGreen.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            shadow: Shadow(
              color: AppColors.positiveGreen.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ),
          // Expense line (red)
          LineChartBarData(
            spots: expenseSpots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColors.negativeRed,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: AppColors.negativeRed,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.negativeRed.withOpacity(0.3),
                  AppColors.negativeRed.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            shadow: Shadow(
              color: AppColors.negativeRed.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ),
        ],
        minY: 0,
        maxY: _getMaxY(monthlyData, divisor),
      ),
    );
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
            BlocBuilder<TransactionCubit, TransactionState>(
              builder: (context, transactionState) {
                final monthlyData = transactionState.status == TransactionStateStatus.loaded
                    ? _calculateMonthlyData(transactionState.transactionsList)
                    : <int, Map<String, double>>{};

                // Determine smart unit based on max amount
                final maxAmount = _getMaxAmount(monthlyData);
                final unitInfo = _getSmartUnit(maxAmount);
                final divisor = (unitInfo['divisor'] as num).toDouble();

                // Always use real data

                // Generate chart spots from real data with smart unit (12 months)
                final incomeSpots = <FlSpot>[];
                final expenseSpots = <FlSpot>[];
                
                for (int month = 1; month <= 12; month++) {
                  final data = monthlyData[month] ?? {'income': 0.0, 'expense': 0.0};
                  incomeSpots.add(FlSpot(month.toDouble(), _convertAmount(data['income']!, divisor)));
                  expenseSpots.add(FlSpot(month.toDouble(), _convertAmount(data['expense']!, divisor)));
                }

                return Container(
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
                              color: AppColors.positiveGreen,
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
                              color: AppColors.negativeRed,
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
                          Spacer(),
                        ],
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: transactionState.status == TransactionStateStatus.loading
                            ? Center(child: CircularProgressIndicator())
                            : _needsScroll(MediaQuery.of(context).size.width)
                                ? _buildScrollableChart(incomeSpots, expenseSpots, monthlyData, divisor, theme)
                                : _buildStaticChart(incomeSpots, expenseSpots, monthlyData, divisor, theme),
                      ),
                    ],
                  ),
                );
              },
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
                              AppLocalizations.of(context)?.noTransactions ?? 'No transactions found',
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
