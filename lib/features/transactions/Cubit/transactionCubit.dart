// ignore_for_file: file_names

import 'package:financy_ui/features/transactions/Cubit/transctionState.dart';
import 'package:financy_ui/features/transactions/models/transactionsModels.dart';
import 'package:financy_ui/features/transactions/repo/transactionsRepo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Transactioncubit extends Cubit<TransactionState> {
  Transactioncubit() : super(TransactionState.initial());

  final TransactionsRepo _transactionsRepo = TransactionsRepo();

  Future<void> fetchTransactionsByDate() async {
    try {
      emit(TransactionState.loading());
      final transactions = await _transactionsRepo.getAllTransactionByDate();
      emit(TransactionState.loaded(transactions));
    } catch (e) {
      emit(TransactionState.error(e.toString()));
    }
  }

  Future<void> addTransaction(Transactionsmodels transaction) async {
    try {
      await _transactionsRepo.saveToLocal(transaction);

      // Add the new transaction to the correct date group in the map
      final updatedMap = Map<DateTime, List<Transactionsmodels>>.from(
        state.transactionsList,
      );
      final txDate = transaction.transactionDate;
      if (txDate != null) {
        if (updatedMap.containsKey(txDate)) {
          updatedMap[txDate] = List<Transactionsmodels>.from(
            updatedMap[txDate]!,
          )..add(transaction);
        } else {
          updatedMap[txDate] = [transaction];
        }
      }
      emit(TransactionState.loaded(updatedMap));

      emit(TransactionState.success());

      // Optionally, fetch the latest transactions from the repository instead of updating the map manually:
    } catch (e) {
      emit(TransactionState.error(e.toString()));
    }
  }

  Future<void> updateTransaction(Transactionsmodels transaction) async {
    try {
      await _transactionsRepo.updateInLocal(transaction);
      final updatedMap = Map<DateTime, List<Transactionsmodels>>.from(
        state.transactionsList,
      );
      final txDate = transaction.transactionDate;
      if (txDate != null && updatedMap.containsKey(txDate)) {
        final updatedList =
            updatedMap[txDate]
                ?.map((t) => t.id == transaction.id ? transaction : t)
                .toList() ??
            [];
        updatedMap[txDate] = updatedList;
      }
      emit(TransactionState.loaded(updatedMap));
      emit(TransactionState.success());
    } catch (e) {
      emit(TransactionState.error(e.toString()));
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _transactionsRepo.deleteFromLocal(id);
      final updatedMap = Map<DateTime, List<Transactionsmodels>>.from(
        state.transactionsList,
      );
      updatedMap.forEach((date, txList) {
        updatedMap[date] = txList.where((t) => t.id != id).toList();
      });
      // Remove any empty lists from the map
      updatedMap.removeWhere((date, txList) => txList.isEmpty);
      emit(TransactionState.loaded(updatedMap));
      emit(TransactionState.success());
    } catch (e) {
      emit(TransactionState.error(e.toString()));
    }
  }
}
