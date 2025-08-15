import 'package:financy_ui/features/Transactions/models/transactionsModels.dart';
import 'package:financy_ui/features/Categories/models/categoriesModels.dart';
import 'package:financy_ui/core/constants/icons.dart';

class StatisticsUtils {
  /// Tính tổng số tiền theo loại giao dịch và khoảng thời gian
  static double calculateTotalAmount(
    Map<DateTime, List<Transactionsmodels>> transactions,
    TransactionType type,
    DateTime startDate,
    DateTime endDate,
  ) {
    double total = 0.0;
    
    transactions.forEach((date, txList) {
      // Normalize dates for comparison (remove time component)
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final normalizedStartDate = DateTime(startDate.year, startDate.month, startDate.day);
      final normalizedEndDate = DateTime(endDate.year, endDate.month, endDate.day);
      
      if (normalizedDate.isAfter(normalizedStartDate.subtract(const Duration(days: 1))) &&
          normalizedDate.isBefore(normalizedEndDate.add(const Duration(days: 1)))) {
        for (var tx in txList) {
          if (tx.type == type) {
            total += tx.amount;
          }
        }
      }
    });
    
    return total;
  }

  /// Tính tổng số tiền theo category và loại giao dịch
  static Map<String, double> calculateAmountByCategory(
    Map<DateTime, List<Transactionsmodels>> transactions,
    TransactionType type,
    DateTime startDate,
    DateTime endDate,
  ) {
    final categoryTotals = <String, double>{};
    
    transactions.forEach((date, txList) {
      // Normalize dates for comparison (remove time component)
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final normalizedStartDate = DateTime(startDate.year, startDate.month, startDate.day);
      final normalizedEndDate = DateTime(endDate.year, endDate.month, endDate.day);
      
      if (normalizedDate.isAfter(normalizedStartDate.subtract(const Duration(days: 1))) &&
          normalizedDate.isBefore(normalizedEndDate.add(const Duration(days: 1)))) {
        for (var tx in txList) {
          if (tx.type == type) {
            categoryTotals[tx.categoriesId] = 
                (categoryTotals[tx.categoriesId] ?? 0.0) + tx.amount;
          }
        }
      }
    });
    
    return categoryTotals;
  }

  /// Tính tổng số tiền theo ngày trong khoảng thời gian
  static Map<DateTime, double> calculateAmountByDate(
    Map<DateTime, List<Transactionsmodels>> transactions,
    TransactionType type,
    DateTime startDate,
    DateTime endDate,
  ) {
    final dateTotals = <DateTime, double>{};
    
    transactions.forEach((date, txList) {
      // Normalize dates for comparison (remove time component)
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final normalizedStartDate = DateTime(startDate.year, startDate.month, startDate.day);
      final normalizedEndDate = DateTime(endDate.year, endDate.month, endDate.day);
      
      if (normalizedDate.isAfter(normalizedStartDate.subtract(const Duration(days: 1))) &&
          normalizedDate.isBefore(normalizedEndDate.add(const Duration(days: 1)))) {
        double dailyTotal = 0.0;
        for (var tx in txList) {
          if (tx.type == type) {
            dailyTotal += tx.amount;
          }
        }
        if (dailyTotal > 0) {
          // Use normalized date as key
          dateTotals[normalizedDate] = dailyTotal;
        }
      }
    });
    
    return dateTotals;
  }

  /// Lấy danh sách categories với thông tin đầy đủ
  static List<Category> getCategoriesForType(TransactionType type) {
    return type == TransactionType.expense 
        ? defaultExpenseCategories 
        : defaultIncomeCategories;
  }

  /// Tính phần trăm cho pie chart
  static Map<String, double> calculatePercentages(Map<String, double> categoryTotals) {
    final total = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);
    if (total == 0) return {};
    
    return categoryTotals.map((category, amount) => 
        MapEntry(category, (amount / total) * 100));
  }

  /// Lấy top categories theo số tiền
  static List<MapEntry<String, double>> getTopCategories(
    Map<String, double> categoryTotals,
    int limit,
  ) {
    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(limit).toList();
  }

  /// Format số tiền thành string
  static String formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  /// Lấy màu cho category
  static String getCategoryColor(String categoryName, TransactionType type) {
    final categories = getCategoriesForType(type);
    final category = categories.firstWhere(
      (cat) => cat.name == categoryName,
      orElse: () => categories.first,
    );
    return category.color;
  }

  /// Lấy icon cho category
  static String getCategoryIcon(String categoryName, TransactionType type) {
    final categories = getCategoriesForType(type);
    final category = categories.firstWhere(
      (cat) => cat.name == categoryName,
      orElse: () => categories.first,
    );
    return category.icon;
  }

  /// Tính toán dữ liệu cho bar chart
  static List<MapEntry<DateTime, double>> getBarChartData(
    Map<DateTime, double> dateTotals,
    int days,
  ) {
    final sortedDates = dateTotals.keys.toList()..sort();
    final recentDates = sortedDates.take(days).toList();
    
    return recentDates.map((date) => 
        MapEntry(date, dateTotals[date] ?? 0.0)).toList();
  }

  /// Tính toán dữ liệu cho pie chart
  static List<MapEntry<String, double>> getPieChartData(
    Map<String, double> categoryTotals,
    int limit,
  ) {
    final topCategories = getTopCategories(categoryTotals, limit);
    final percentages = calculatePercentages(categoryTotals);
    
    return topCategories.map((entry) => 
        MapEntry(entry.key, percentages[entry.key] ?? 0.0)).toList();
  }
}
