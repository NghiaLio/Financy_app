// ignore_for_file: file_names, unrelated_type_equality_checks

// import 'package:financy_ui/features/Account/models/money_source.dart';
// import 'package:financy_ui/features/Account/repo/manageMoneyRepo.dart';
import 'package:financy_ui/features/Transactions/models/transactionsModels.dart';
import 'package:hive/hive.dart';

class TransactionsRepo {
  // final ManageMoneyRepo _manageMoneyRepo =ManageMoneyRepo();

  static const String _boxName = 'transactions';
  static Box<Transactionsmodels>? _box;

  /// Initialize Hive box for local storage
  static Future<void> initializeLocalStorage() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<Transactionsmodels>(_boxName);
    }
  }

  /// Get the Hive box
  static Box<Transactionsmodels> get _localBox {
    if (_box == null || !_box!.isOpen) {
      throw Exception(
        'Local storage not initialized. Call initializeLocalStorage() first.',
      );
    }
    return _box!;
  }

  // ==================== LOCAL STORAGE METHODS ====================

  Future<void> saveToLocal(Transactionsmodels transaction) async {
    await _localBox.add(transaction);
  }

  Future<Map<DateTime, List<Transactionsmodels>>>
  getAllTransactionByDate() async {
    final allTransactions = _localBox.values.toList();
    final groupedTransactions = <DateTime, List<Transactionsmodels>>{};

    for (var tx in allTransactions) {
      final dateOnly = DateTime(
        tx.transactionDate?.year ?? 0,
        tx.transactionDate?.month ?? 0,
        tx.transactionDate?.day ?? 0,
      );
      groupedTransactions.putIfAbsent(dateOnly, () => []).add(tx);
    }

    // Sắp xếp theo ngày giảm dần (mới nhất trước)
    final sortedKeys =
        groupedTransactions.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (var key in sortedKeys) key: groupedTransactions[key] ?? []};
  }

  Future<Map<DateTime, List<Transactionsmodels>>>
  getAllTransactionByAccount(String accountId) async {
    final allTransactions = _localBox.values.toList();
    final groupedTransactions = <DateTime, List<Transactionsmodels>>{};

    for (var tx in allTransactions) {
      if (tx.accountId == accountId) {
        final dateOnly = DateTime(
          tx.transactionDate?.year ?? 0,
          tx.transactionDate?.month ?? 0,
          tx.transactionDate?.day ?? 0,
        );
        groupedTransactions.putIfAbsent(dateOnly, () => []).add(tx);
      }
    }

    // Sắp xếp theo ngày giảm dần (mới nhất trước)
    final sortedKeys =
        groupedTransactions.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (var key in sortedKeys) key: groupedTransactions[key] ?? []};
  }

  Future<void> updateInLocal(Transactionsmodels transaction) async {
    final index = _localBox.values.toList().indexWhere(
      (t) => t.id == transaction.id,
    );
    if (index != -1) {
      await _localBox.putAt(index, transaction);
    } else {
      throw Exception('Transaction not found');
    }
  }

  Future<void> deleteFromLocal(String id) async {
    final index = _localBox.values.toList().indexWhere((t) => t.id == id);
    if (index != -1) {
      await _localBox.deleteAt(index);
    } else {
      throw Exception('Transaction not found');
    }
  }
}
