// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financy_ui/features/Transactions/Cubit/transactionCubit.dart';
import 'package:financy_ui/features/Transactions/Cubit/transctionState.dart';
import 'package:financy_ui/features/Transactions/models/transactionsModels.dart';
import 'package:financy_ui/features/Categories/cubit/CategoriesCubit.dart';
import 'package:financy_ui/features/Categories/cubit/CategoriesState.dart';
import 'package:financy_ui/shared/utils/statistics_utils.dart';

enum StatisticsView { daily, weekly, monthly, yearly }

class Income extends StatefulWidget {
  const Income({super.key});

  @override
  State<Income> createState() => _IncomeState();
}

class _IncomeState extends State<Income> {
  // Filter selections
  StatisticsView selectedView = StatisticsView.daily;
  String selectedCategory = 'All Categories';
  DateTime selectedDate = DateTime.now();
  
  // Statistics data
  double totalIncome = 0.0;
  Map<String, double> categoryTotals = {};
  List<MapEntry<DateTime, double>> chartData = [];
  List<MapEntry<String, double>> pieChartData = [];
  
  // UI data
  List<String> categories = ['All Categories'];
  List<String> availableYears = [];
  List<String> availableMonths = [];
  List<String> availableWeeks = [];
  
  @override
  void initState() {
    super.initState();
    _initializeAvailableOptions();
    context.read<TransactionCubit>().fetchTransactionsByDate();
    context.read<Categoriescubit>().loadCategories();
  }

  void _initializeAvailableOptions() {
    final now = DateTime.now();
    
    // Initialize years (current year and 3 years back)
    availableYears = List.generate(4, (index) => (now.year - index).toString());
    
    // Initialize months for current year
    availableMonths = List.generate(12, (index) {
      final month = index + 1;
      return '$month/${now.year}';
    });
    
    // Initialize weeks for current month
    _updateAvailableWeeks();
  }

  void _updateAvailableWeeks() {
    availableWeeks.clear();
    final year = selectedDate.year;
    final month = selectedDate.month;
    
    // Get first day of month and calculate weeks
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    
    DateTime current = firstDay;
    int weekNumber = 1;
    
    while (current.isBefore(lastDay) || current.isAtSameMomentAs(lastDay)) {
      final weekStart = current.subtract(Duration(days: current.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      
      availableWeeks.add('Week $weekNumber (${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month})');
      current = current.add(const Duration(days: 7));
      weekNumber++;
    }
  }

  void _calculateStatistics(Map<DateTime, List<Transactionsmodels>> transactions) {
    final (startDate, endDate) = _getDateRange();
    
    // Filter transactions by date range and category
    final filteredTransactions = _filterTransactions(transactions, startDate, endDate);
    
    // Calculate total income
    totalIncome = _calculateTotalIncome(filteredTransactions);
    
    // Calculate category totals for pie chart
    categoryTotals = _calculateCategoryTotals(filteredTransactions);
    
    // Calculate chart data based on selected view
    chartData = _calculateChartData(filteredTransactions, startDate, endDate);
    
    // Calculate pie chart data
    pieChartData = StatisticsUtils.getPieChartData(categoryTotals, 5);
    
    setState(() {});
  }

  (DateTime, DateTime) _getDateRange() {
    DateTime startDate, endDate;
    
    switch (selectedView) {
      case StatisticsView.daily:
        // Show current month for daily view
        startDate = DateTime(selectedDate.year, selectedDate.month, 1);
        endDate = DateTime(selectedDate.year, selectedDate.month + 1, 0);
        break;
        
      case StatisticsView.weekly:
        // Get start and end of selected week
        final weekStart = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
        startDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
        endDate = startDate.add(const Duration(days: 6));
        break;
        
      case StatisticsView.monthly:
        // Show current year for monthly view
        startDate = DateTime(selectedDate.year, 1, 1);
        endDate = DateTime(selectedDate.year, 12, 31);
        break;
        
      case StatisticsView.yearly:
        // Show multiple years for yearly view
        startDate = DateTime(selectedDate.year - 3, 1, 1);
        endDate = DateTime(selectedDate.year, 12, 31);
        break;
    }
    
    return (startDate, endDate);
  }

  Map<DateTime, List<Transactionsmodels>> _filterTransactions(
    Map<DateTime, List<Transactionsmodels>> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    final filtered = <DateTime, List<Transactionsmodels>>{};
    
    transactions.forEach((date, txList) {
      // Filter by date range
      if (date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(endDate.add(const Duration(days: 1)))) {
        
        // Filter by category if not "All Categories"
        List<Transactionsmodels> categoryFiltered = txList;
        if (selectedCategory != 'All Categories') {
          categoryFiltered = txList.where((tx) => 
            tx.type == TransactionType.income && tx.categoriesId == selectedCategory
          ).toList();
        } else {
          categoryFiltered = txList.where((tx) => 
            tx.type == TransactionType.income
          ).toList();
        }
        
        if (categoryFiltered.isNotEmpty) {
          filtered[date] = categoryFiltered;
        }
      }
    });
    
    return filtered;
  }

  double _calculateTotalIncome(Map<DateTime, List<Transactionsmodels>> transactions) {
    double total = 0.0;
    transactions.forEach((date, txList) {
      for (var tx in txList) {
        total += tx.amount;
      }
    });
    return total;
  }

  Map<String, double> _calculateCategoryTotals(Map<DateTime, List<Transactionsmodels>> transactions) {
    final categoryTotals = <String, double>{};
    
    transactions.forEach((date, txList) {
      for (var tx in txList) {
        categoryTotals[tx.categoriesId] = (categoryTotals[tx.categoriesId] ?? 0.0) + tx.amount;
      }
    });
    
    return categoryTotals;
  }

  List<MapEntry<DateTime, double>> _calculateChartData(
    Map<DateTime, List<Transactionsmodels>> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    switch (selectedView) {
      case StatisticsView.daily:
        return _calculateDailyData(transactions, startDate, endDate);
      case StatisticsView.weekly:
        return _calculateWeeklyData(transactions, startDate, endDate);
      case StatisticsView.monthly:
        return _calculateMonthlyData(transactions, startDate, endDate);
      case StatisticsView.yearly:
        return _calculateYearlyData(transactions, startDate, endDate);
    }
  }

  List<MapEntry<DateTime, double>> _calculateDailyData(
    Map<DateTime, List<Transactionsmodels>> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    final dailyData = <MapEntry<DateTime, double>>[];
    DateTime current = startDate;
    
    while (current.isBefore(endDate.add(const Duration(days: 1)))) {
      double dailyTotal = 0.0;
      final txList = transactions[current] ?? [];
      
      for (var tx in txList) {
        dailyTotal += tx.amount;
      }
      
      dailyData.add(MapEntry(current, dailyTotal));
      current = current.add(const Duration(days: 1));
    }
    
    return dailyData;
  }

  List<MapEntry<DateTime, double>> _calculateWeeklyData(
    Map<DateTime, List<Transactionsmodels>> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    final weeklyData = <MapEntry<DateTime, double>>[];
    DateTime current = startDate;
    
    while (current.isBefore(endDate)) {
      final weekStart = current.subtract(Duration(days: current.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      
      double weeklyTotal = 0.0;
      DateTime weekCurrent = weekStart;
      
      while (weekCurrent.isBefore(weekEnd.add(const Duration(days: 1)))) {
        final txList = transactions[weekCurrent] ?? [];
        for (var tx in txList) {
          weeklyTotal += tx.amount;
        }
        weekCurrent = weekCurrent.add(const Duration(days: 1));
      }
      
      weeklyData.add(MapEntry(weekStart, weeklyTotal));
      current = weekEnd.add(const Duration(days: 1));
    }
    
    return weeklyData;
  }

  List<MapEntry<DateTime, double>> _calculateMonthlyData(
    Map<DateTime, List<Transactionsmodels>> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    final monthlyData = <MapEntry<DateTime, double>>[];
    DateTime current = DateTime(startDate.year, startDate.month, 1);
    
    while (current.isBefore(endDate)) {
      final monthStart = DateTime(current.year, current.month, 1);
      final monthEnd = DateTime(current.year, current.month + 1, 0);
      
      double monthlyTotal = 0.0;
      DateTime monthCurrent = monthStart;
      
      while (monthCurrent.isBefore(monthEnd.add(const Duration(days: 1)))) {
        final txList = transactions[monthCurrent] ?? [];
        for (var tx in txList) {
          monthlyTotal += tx.amount;
        }
        monthCurrent = monthCurrent.add(const Duration(days: 1));
      }
      
      monthlyData.add(MapEntry(monthStart, monthlyTotal));
      current = DateTime(current.year, current.month + 1, 1);
    }
    
    return monthlyData;
  }

  List<MapEntry<DateTime, double>> _calculateYearlyData(
    Map<DateTime, List<Transactionsmodels>> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    final yearlyData = <MapEntry<DateTime, double>>[];
    DateTime current = DateTime(startDate.year, 1, 1);
    
    while (current.year <= endDate.year) {
      final yearStart = DateTime(current.year, 1, 1);
      final yearEnd = DateTime(current.year, 12, 31);
      
      double yearlyTotal = 0.0;
      DateTime yearCurrent = yearStart;
      
      while (yearCurrent.year == current.year) {
        final txList = transactions[yearCurrent] ?? [];
        for (var tx in txList) {
          yearlyTotal += tx.amount;
        }
        yearCurrent = yearCurrent.add(const Duration(days: 1));
        if (yearCurrent.isAfter(yearEnd)) break;
      }
      
      yearlyData.add(MapEntry(yearStart, yearlyTotal));
      current = DateTime(current.year + 1, 1, 1);
    }
    
    return yearlyData;
  }

  String _getChartTitle() {
    switch (selectedView) {
      case StatisticsView.daily:
        return 'Daily Income';
      case StatisticsView.weekly:
        return 'Weekly Income';
      case StatisticsView.monthly:
        return 'Monthly Income';
      case StatisticsView.yearly:
        return 'Yearly Income';
    }
  }

  String _getDateLabel(DateTime date) {
    switch (selectedView) {
      case StatisticsView.daily:
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final dateOnly = DateTime(date.year, date.month, date.day);
        
        if (dateOnly == today) {
          return 'Today';
        } else if (dateOnly == today.subtract(const Duration(days: 1))) {
          return 'Yesterday';
        } else {
          return '${date.day}/${date.month}';
        }
        
      case StatisticsView.weekly:
        final weekEnd = date.add(const Duration(days: 6));
        return 'W${_getWeekNumber(date)}\n${date.day}/${date.month}-${weekEnd.day}/${weekEnd.month}';
        
      case StatisticsView.monthly:
        return _getMonthName(date.month);
        
      case StatisticsView.yearly:
        return date.year.toString();
    }
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(firstDayOfYear).inDays + 1;
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month - 1];
  }

  double _getMaxY() {
    if (chartData.isEmpty) return 100;
    final maxValue = chartData.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return maxValue > 0 ? maxValue * 1.2 : 100;
  }

  double _calculateChartWidth() {
    // Tính toán độ rộng cần thiết dựa trên số lượng data points
    if (chartData.isEmpty) return 300.0; // Minimum width khi không có data
    
    final double barWidth = _getBarWidth();
    final double spacing = 24; // Khoảng cách giữa các bars
    final double leftPadding = 75; // Cho left titles
    final double rightPadding = 20;
    
    final double calculatedWidth = leftPadding + rightPadding + (chartData.length * (barWidth + spacing));
    return calculatedWidth.clamp(300.0, double.infinity); // Đảm bảo width tối thiểu
  }

  Widget _buildScrollableChart(ThemeData theme, double chartWidth) {
    final ScrollController scrollController = ScrollController();
    
    // Auto scroll to today để hiển thị ngày hôm nay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients && chartData.isNotEmpty) {
        final screenWidth = MediaQuery.of(context).size.width - 64;
        final shouldScroll = chartWidth > screenWidth;
        
        if (shouldScroll) {
          // Tìm vị trí của ngày hôm nay trong chartData
          final today = DateTime.now();
          final todayNormalized = DateTime(today.year, today.month, today.day);
          
          int todayIndex = -1;
          for (int i = 0; i < chartData.length; i++) {
            final chartDate = chartData[i].key;
            final chartDateNormalized = DateTime(chartDate.year, chartDate.month, chartDate.day);
            if (chartDateNormalized.isAtSameMomentAs(todayNormalized)) {
              todayIndex = i;
              break;
            }
          }
          
          // Nếu không tìm thấy ngày hôm nay, tìm ngày gần nhất
          if (todayIndex == -1) {
            todayIndex = chartData.length - 1; // Fallback to latest
            for (int i = chartData.length - 1; i >= 0; i--) {
              final chartDate = chartData[i].key;
              if (chartDate.isBefore(today) || chartDate.isAtSameMomentAs(today)) {
                todayIndex = i;
                break;
              }
            }
          }
          
          // Tính toán scroll offset để center ngày hôm nay
          final barWidth = _getBarWidth() + 24; // bar width + spacing
          final visibleBars = (screenWidth / barWidth).floor();
          final centerOffset = (visibleBars / 2).floor();
          
          // Scroll để hiển thị today ở giữa màn hình (hoặc về phía phải nếu có thể)
          final maxVisibleBars = (visibleBars > 0) ? visibleBars : 1;
          final maxTargetIndex = (chartData.length - maxVisibleBars).clamp(0, chartData.length - 1);
          final targetIndex = (todayIndex - centerOffset + 3).clamp(0, maxTargetIndex);
          final maxScrollOffset = (chartWidth - screenWidth).clamp(0.0, double.infinity);
          final scrollOffset = (targetIndex * barWidth).clamp(0.0, maxScrollOffset);
          
          if (scrollOffset > 0 && scrollOffset.isFinite) {
            scrollController.animateTo(
              scrollOffset,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        }
      }
    });
    
    return Stack(
      children: [
        SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: chartWidth,
            child: _buildBarChartWidget(theme),
          ),
        ),
        // Scroll indicators - chỉ che phần chart, không che left titles
        Positioned(
          left: 75, // Bắt đầu sau left titles (reservedSize: 65 + padding)
          top: 0,
          bottom: 40, // Không che bottom titles
          child: Container(
            width: 12, // Giảm width để ít che hơn
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
          bottom: 40, // Không che bottom titles
          child: Container(
            width: 12, // Giảm width để đồng bộ với bên trái
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
        // "Today" indicator - chỉ hiển thị khi có scroll và có ngày hôm nay
        if (_shouldShowTodayIndicator())
          Positioned(
            right: 25,
            top: 10,
            child: GestureDetector(
              onTap: () => _scrollToToday(scrollController),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.4),
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
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Hôm nay',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green,
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

  Widget _buildStaticChart(ThemeData theme) {
    return _buildBarChartWidget(theme);
  }

  bool _shouldShowTodayIndicator() {
    // Chỉ hiển thị nút "Hôm nay" khi:
    // 1. Đang ở daily view
    // 2. Có data trong chart
    // 3. Có ngày hôm nay trong chart data
    if (selectedView != StatisticsView.daily || chartData.isEmpty) {
      return false;
    }

    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    
    return chartData.any((entry) {
      final chartDate = entry.key;
      final chartDateNormalized = DateTime(chartDate.year, chartDate.month, chartDate.day);
      return chartDateNormalized.isAtSameMomentAs(todayNormalized);
    });
  }

  void _scrollToToday(ScrollController scrollController) {
    if (!scrollController.hasClients || chartData.isEmpty) return;
    
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    
    int todayIndex = -1;
    for (int i = 0; i < chartData.length; i++) {
      final chartDate = chartData[i].key;
      final chartDateNormalized = DateTime(chartDate.year, chartDate.month, chartDate.day);
      if (chartDateNormalized.isAtSameMomentAs(todayNormalized)) {
        todayIndex = i;
        break;
      }
    }
    
    if (todayIndex == -1) return;
    
    final screenWidth = MediaQuery.of(context).size.width - 64;
    final barWidth = _getBarWidth() + 24; // bar width + spacing
    final visibleBars = (screenWidth / barWidth).floor().clamp(1, chartData.length);
    final centerOffset = (visibleBars / 2).floor();
    
    // Tính toán an toàn cho scroll offset
    final chartWidth = _calculateChartWidth();
    final maxScrollOffset = (chartWidth - screenWidth).clamp(0.0, double.infinity);
    
    if (maxScrollOffset <= 0) return; // Không cần scroll nếu chart nhỏ hơn screen
    
    final maxTargetIndex = (chartData.length - visibleBars).clamp(0, chartData.length - 1);
    final targetIndex = (todayIndex - centerOffset + 1).clamp(0, maxTargetIndex);
    final scrollOffset = (targetIndex * barWidth).clamp(0.0, maxScrollOffset);
    
    if (scrollOffset.isFinite && scrollOffset >= 0) {
      scrollController.animateTo(
        scrollOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildBarChartWidget(ThemeData theme) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        maxY: _getMaxY(),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBorder: BorderSide(
              color: Colors.green.withOpacity(0.8),
              width: 1,
            ),
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            tooltipMargin: 8,
            getTooltipColor: (group) => theme.colorScheme.surface.withOpacity(0.95),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (group.x >= chartData.length) return null;
              final data = chartData[group.x];
              return BarTooltipItem(
                '${_getDateLabel(data.key)}\n${StatisticsUtils.formatAmount(rod.toY)} VND',
                theme.textTheme.bodySmall!.copyWith(
                  color: theme.textTheme.bodySmall!.color,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= chartData.length) return const Text('');
                final date = chartData[value.toInt()].key;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _getDateLabel(date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: theme.textTheme.bodySmall?.color,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: selectedView == StatisticsView.weekly ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
              reservedSize: selectedView == StatisticsView.weekly ? 50 : 35,
              interval: 1, // Hiển thị tất cả labels khi có scroll
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  StatisticsUtils.formatAmount(value),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                );
              },
              reservedSize: 65,
              interval: _getMaxY() / 4,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: _getMaxY() / 4,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.dividerColor.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: theme.dividerColor.withOpacity(0.1),
              strokeWidth: 0.5,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: _buildBarGroups(),
      ),
    );
  }

  double _getBarWidth() {
    switch (selectedView) {
      case StatisticsView.daily:
        return 32;
      case StatisticsView.weekly:
        return 28;
      case StatisticsView.monthly:
        return 24;
      case StatisticsView.yearly:
        return 36;
    }
  }

  List<BarChartGroupData> _buildBarGroups() {
    final double barWidth = _getBarWidth();
    
    return chartData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data.value,
            color: data.value > 0 
                ? Colors.green
                : Colors.green.withOpacity(0.3),
            width: barWidth,
            borderRadius: BorderRadius.circular(6),
            gradient: data.value > 0 
                ? LinearGradient(
                    colors: [
                      Colors.green.withOpacity(0.8),
                      Colors.green,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  )
                : null,
          ),
        ],
      );
    }).toList();
  }

  List<PieChartSectionData> _buildPieSections() {
    if (pieChartData.isEmpty) {
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 100,
          title: 'No Data',
          titleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          radius: 40,
        ),
      ];
    }

    final colors = [Colors.green, Colors.blue, Colors.purple, Colors.orange, Colors.teal];
    
    return pieChartData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: data.value,
        title: '${data.value.toStringAsFixed(1)}%',
        titleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        radius: 40,
      );
    }).toList();
  }

  List<Widget> _buildLegendItems() {
    if (pieChartData.isEmpty) {
      return [
        _buildLegendItem(Colors.grey, 'Không có dữ liệu'),
      ];
    }

    final colors = [Colors.green, Colors.blue, Colors.purple, Colors.orange, Colors.teal];
    
    return pieChartData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return Column(
        children: [
          _buildLegendItem(colors[index % colors.length], data.key),
          const SizedBox(height: 8),
        ],
      );
    }).toList();
  }

  String _getPeriodDescription() {
    final (startDate, endDate) = _getDateRange();
    
    switch (selectedView) {
      case StatisticsView.daily:
        return '${_getMonthName(selectedDate.month)} ${selectedDate.year}';
      case StatisticsView.weekly:
        return 'Week of ${startDate.day}/${startDate.month}/${startDate.year}';
      case StatisticsView.monthly:
        return 'Year ${startDate.year}';
      case StatisticsView.yearly:
        return '${startDate.year} - ${endDate.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return MultiBlocListener(
      listeners: [
        BlocListener<TransactionCubit, TransactionState>(
          listener: (context, state) {
            if (state.status == TransactionStateStatus.loaded) {
              _calculateStatistics(state.transactionsList);
            }
          },
        ),
        BlocListener<Categoriescubit, CategoriesState>(
          listener: (context, state) {
            if (state.status == CategoriesStatus.loaded) {
              setState(() {
                categories = ['All Categories', ...state.categoriesIncome.map((c) => c.name)];
              });
            }
          },
        ),
      ],
      child: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          if (state.status == TransactionStateStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Header
                _buildSummaryHeader(theme, l10n),
                const SizedBox(height: 24),
                
                // Filter Controls
                _buildFilterControls(theme, l10n),
                const SizedBox(height: 24),
                
                // Bar Chart
                _buildBarChart(theme, l10n),
                const SizedBox(height: 32),
                
                // Pie Chart Section
                _buildPieChartSection(theme, l10n),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryHeader(ThemeData theme, AppLocalizations? l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n?.income ?? 'Income',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '+${StatisticsUtils.formatAmount(totalIncome)} VND',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _getPeriodDescription(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterControls(ThemeData theme, AppLocalizations? l10n) {
    return Column(
      children: [
        // View and Category Selection
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                _getViewText(),
                () => _showViewSelector(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                selectedCategory,
                () => _showCategorySelector(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Date Selection (centered)
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                _getDateText(),
                () => _showDateSelector(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getViewText() {
    switch (selectedView) {
      case StatisticsView.daily:
        return 'Daily View';
      case StatisticsView.weekly:
        return 'Weekly View';
      case StatisticsView.monthly:
        return 'Monthly View';
      case StatisticsView.yearly:
        return 'Yearly View';
    }
  }

  String _getDateText() {
    switch (selectedView) {
      case StatisticsView.daily:
        return '${_getMonthName(selectedDate.month)} ${selectedDate.year}';
      case StatisticsView.weekly:
        return 'W${_getWeekNumber(selectedDate)} ${selectedDate.year}';
      case StatisticsView.monthly:
        return selectedDate.year.toString();
      case StatisticsView.yearly:
        return '${selectedDate.year - 3} - ${selectedDate.year}';
    }
  }

  Widget _buildBarChart(ThemeData theme, AppLocalizations? l10n) {
    // Tính toán độ rộng cần thiết cho chart
    final double chartWidth = _calculateChartWidth();
    final double screenWidth = MediaQuery.of(context).size.width - 64; // 64 = padding
    final bool needsScroll = chartData.length > 3 && chartWidth > screenWidth; // Chỉ scroll khi có nhiều data và cần thiết
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      height: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8), // Giảm padding dưới title
            child: Row(
              children: [
                Text(
                  _getChartTitle(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16, // Giảm font size một chút
                  ),
                ),
                const Spacer(),
                if (needsScroll)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.swipe_left,
                        size: 14, // Giảm icon size
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Scroll để xem thêm',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                          fontStyle: FontStyle.italic,
                          fontSize: 10, // Giảm font size
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Expanded(
            child: needsScroll 
                ? _buildScrollableChart(theme, chartWidth)
                : _buildStaticChart(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartSection(ThemeData theme, AppLocalizations? l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.compareIncomeTypes ?? 'Income by Categories',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Pie Chart
              SizedBox(
                width: 140,
                height: 140,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 45,
                    sections: _buildPieSections(),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              
              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildLegendItems(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String text, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down,
              color: theme.iconTheme.color,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Selector Methods
  void _showViewSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select View'),
        contentPadding: const EdgeInsets.only(top: 20),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: StatisticsView.values.map((view) {
              return ListTile(
                title: Text(
                  _getViewName(view),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: selectedView == view 
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).primaryColor,
                      )
                    : null,
                onTap: () {
                  setState(() {
                    selectedView = view;
                  });
                  Navigator.pop(context);
                  context.read<TransactionCubit>().fetchTransactionsByDate();
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCategorySelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Category'),
        contentPadding: const EdgeInsets.only(top: 20),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                title: Text(
                  category,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: selectedCategory == category 
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).primaryColor,
                      )
                    : null,
                onTap: () {
                  setState(() {
                    selectedCategory = category;
                  });
                  Navigator.pop(context);
                  context.read<TransactionCubit>().fetchTransactionsByDate();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showDateSelector() {
    switch (selectedView) {
      case StatisticsView.daily:
        _showMonthSelector();
        break;
      case StatisticsView.weekly:
        _showWeekSelector();
        break;
      case StatisticsView.monthly:
        _showYearSelector();
        break;
      case StatisticsView.yearly:
        _showYearSelector();
        break;
    }
  }

  void _showYearSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Year'),
        contentPadding: const EdgeInsets.only(top: 20),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: availableYears.map((year) {
              return ListTile(
                title: Text(year),
                onTap: () {
                  setState(() {
                    selectedDate = DateTime(int.parse(year), selectedDate.month, selectedDate.day);
                  });
                  Navigator.pop(context);
                  context.read<TransactionCubit>().fetchTransactionsByDate();
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showMonthSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Month'),
        contentPadding: const EdgeInsets.only(top: 20),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final isSelected = selectedDate.month == month;
              return ListTile(
                title: Text(
                  '${_getMonthName(month)} ${selectedDate.year}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).primaryColor,
                      )
                    : null,
                onTap: () {
                  setState(() {
                    selectedDate = DateTime(selectedDate.year, month, 1);
                    _updateAvailableWeeks();
                  });
                  Navigator.pop(context);
                  context.read<TransactionCubit>().fetchTransactionsByDate();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }



  void _showWeekSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Week'),
        contentPadding: const EdgeInsets.only(top: 20),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableWeeks.length,
            itemBuilder: (context, index) {
              final weekText = availableWeeks[index];
              return ListTile(
                title: Text(
                  weekText,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: () {
                  final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
                  final weekStartDate = firstDayOfMonth.add(Duration(days: index * 7));
                  
                  setState(() {
                    selectedDate = weekStartDate;
                  });
                  Navigator.pop(context);
                  context.read<TransactionCubit>().fetchTransactionsByDate();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _getViewName(StatisticsView view) {
    switch (view) {
      case StatisticsView.daily:
        return 'Daily View';
      case StatisticsView.weekly:
        return 'Weekly View';
      case StatisticsView.monthly:
        return 'Monthly View';
      case StatisticsView.yearly:
        return 'Yearly View';
    }
  }
}
